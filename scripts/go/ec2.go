package main

import (
	"log"
	"os/exec"

	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

const keyFile = "../../terraform/workflow-3/key.pem"

func getEC2Name(resourcePrefix string) string {
	return resourcePrefix + "-ec2"
}

func getEC2Instance(ec2 *ec2.EC2) *string {
	result, err := ec2.DescribeInstances(nil)
	if err != nil {
		log.Fatalf("Failed to describe instances: %s", err.Error())
	}

	ec2Name := getEC2Name(variables["resource_name_prefix"])
	for _, reservation := range result.Reservations {
		for _, instance := range reservation.Instances {
			if *instance.State.Name == "running" {
				for _, tag := range instance.Tags {
					if *tag.Key == "Name" && *tag.Value == ec2Name {
						log.Println(*instance.State.Name)
						return instance.PublicIpAddress
					}
				}
			}
		}
	}

	return nil
}

func produceEC2Logs(sess *session.Session) {
	ec2 := ec2.New(sess)

	ipAddress := getEC2Instance(ec2)

	if ipAddress == nil {
		log.Fatal("EC2 instance not found.")
	}

	cmd := exec.Command("ssh", "-i", keyFile, "ubuntu@"+*ipAddress)

	err := cmd.Run()
	if err != nil {
		log.Fatalf("Error connecting to EC2 instance: %s", err.Error())
	}

}
