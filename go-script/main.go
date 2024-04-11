package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
)

const terraformDir = "../terraform"

var variables = make(map[string]string)
var workflows = make(map[string]bool)

func readVariables() error {
	files, err := os.ReadDir(terraformDir)
	if err != nil {
		return fmt.Errorf("failed to open directory %s for the terraform variables: %s", terraformDir, err.Error())
	}

	for _, filename := range files {
		if !filename.IsDir() && strings.Contains(filename.Name(), ".auto.tfvars") {
			filepath := terraformDir + "/" + filename.Name()
			file, err := os.Open(filepath)
			if err == nil {
				log.Printf("File %s was opened. Looking for variables there...\n", filepath)
				scanner := bufio.NewScanner(file)
				// Check which variables are in this file
				for scanner.Scan() {
					line := scanner.Text()
					variable := strings.Split(line, "=")
					if len(variable) == 2 {
						name := strings.TrimSpace(variable[0])
						value := strings.TrimSpace(variable[1])

						// Check if it is the workflow list
						if string(value[0]) == `[` {
							log.Printf("\tFound variable %s with value %s.", name, value)
							value = strings.Trim(value, `[]`)
							numbers := strings.Split(value, ",")
							for _, number := range numbers {
								number = strings.TrimSpace(number)
								workflows[number] = true
							}
						} else {
							// otherwise it is a string
							value = strings.Trim(value, `\"\"`)
							log.Printf("\tFound variable %s with value %s.", name, value)
							variables[name] = value
						}
					}
				}
				_ = file.Close()
			} else {
				log.Printf("Could not open file %s, variables there will be ignored: %s\n", filepath, err.Error())
			}
		}
	}
	return nil
}

func createSession() *session.Session {
	awsRegion, exists := variables["aws_region"]
	if !exists {
		log.Fatal("Please, ensure your *.auto.tfvars file has variable aws_region defined.")
	}
	accessKeyId, exists := variables["aws_access_key"]
	if !exists {
		log.Fatal("Please, ensure your *.auto.tfvars file has variable aws_access_key defined.")
	}
	secretKey, exists := variables["aws_secret_key"]
	if !exists {
		log.Fatal("Please, ensure your *.auto.tfvars file has variable aws_secret_key defined.")
	}
	_, exists = variables["resource_name_prefix"]
	if !exists {
		log.Fatal("Please, ensure your *.auto.tfvars file has variable resource_name_prefix defined.")
	}

	credentialsValue := credentials.Value{
		AccessKeyID:     accessKeyId,
		SecretAccessKey: secretKey,
	}

	sess, err := session.NewSessionWithOptions(session.Options{
		Config: aws.Config{
			Region:      &awsRegion,
			Credentials: credentials.NewStaticCredentialsFromCreds(credentialsValue),
		},
	})
	if err != nil {
		log.Fatal("Not possible to open AWS session: ", err.Error())
	}

	return sess
}

func main() {
	// Remove the timestamp from the logs
	log.SetFlags(0)

	if err := readVariables(); err != nil {
		log.Fatal(err)
	}

	if len(workflows) == 0 {
		log.Fatal("There are no workflows to test.")
	}

	sess := createSession()

	if _, exists := workflows["1"]; exists {
		log.Println("Testing workflow-1.")
		produceCloudfrontLogs(sess)
	}

	if _, exists := workflows["2"]; exists {
		log.Println("Testing workflow-2.")
		produceCloudwatchLogs(sess)
	}
}
