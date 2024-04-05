package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"

	"github.com/aws/aws-sdk-go/aws"
)

const terraformDir = "../terraform"

var variables = make(map[string]string)

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
						value = strings.Trim(value, `\"\"`)
						log.Printf("\tFound variable %s with value %s.", name, value)
						variables[name] = value
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

func getGroupName(resourcePrefix string) string {
	return resourcePrefix + "-cloudwatch-lg"
}

func getLogGroup(cloudwatchLogs *cloudwatchlogs.CloudWatchLogs, resourcePrefix string) *cloudwatchlogs.LogGroup {
	resp, err := cloudwatchLogs.DescribeLogGroups(&cloudwatchlogs.DescribeLogGroupsInput{
		LogGroupNamePrefix: &resourcePrefix,
	})
	if err != nil {
		log.Fatal(err)
	}

	logGroupName := getGroupName(resourcePrefix)
	for _, logGroup := range resp.LogGroups {
		if *logGroup.LogGroupName == logGroupName {
			return logGroup
		}
	}

	return nil
}

// createLogStream creates a new log stream and returns the stream name
func createLogStream(cloudwatchLogs *cloudwatchlogs.CloudWatchLogs, groupName string) string {
	name := "stream-" + strconv.FormatInt(time.Now().UnixNano(), 10)

	_, err := cloudwatchLogs.CreateLogStream(&cloudwatchlogs.CreateLogStreamInput{
		LogGroupName:  &groupName,
		LogStreamName: &name,
	})
	if err != nil {
		log.Fatalf("Failed to create log stream in log group %s: %s", groupName, err.Error())
	}
	return name
}

func main() {
	// Remove the timestamp from the logs
	log.SetFlags(0)

	if err := readVariables(); err != nil {
		log.Fatal(err)
	}

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
	resourceNamePrefix, exists := variables["resource_name_prefix"]
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
		log.Fatal(err)
	}

	cloudwatchLogs := cloudwatchlogs.New(sess)
	logGroup := getLogGroup(cloudwatchLogs, resourceNamePrefix)

	groupName := getGroupName(resourceNamePrefix)
	if logGroup == nil {
		log.Fatalf("Log group %s does not exist.", groupName)
	}

	// Create a new log stream to receive the new log events
	streamName := createLogStream(cloudwatchLogs, groupName)

	log.Printf("Sending data to log stream %s in log group %s.", streamName, groupName)

	for {
		var events []*cloudwatchlogs.InputLogEvent

		nEvents := 5

		for i := 0; i < nEvents; i++ {
			message := "Some test message - iteration " + strconv.Itoa(i)
			event := &cloudwatchlogs.InputLogEvent{
				Message:   &message,
				Timestamp: aws.Int64(time.Now().UnixNano() / int64(time.Millisecond)),
			}

			events = append(events, event)
		}

		input := cloudwatchlogs.PutLogEventsInput{
			LogEvents:     events,
			LogGroupName:  &groupName,
			LogStreamName: &streamName,
		}

		log.Println("\tSending ", nEvents, " log events...")
		_, err = cloudwatchLogs.PutLogEvents(&input)
		if err != nil {
			log.Fatal(err)
		}

		sleepTime := 30 * time.Second
		log.Println("\tSleeping ", sleepTime, "...")
		time.Sleep(sleepTime)

		log.Println()
	}

}
