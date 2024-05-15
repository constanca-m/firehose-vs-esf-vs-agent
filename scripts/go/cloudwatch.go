package main

import (
	"log"
	"strconv"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
)

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

func produceCloudwatchLogs(sess *session.Session) {
	cloudwatchLogs := cloudwatchlogs.New(sess)
	logGroup := getLogGroup(cloudwatchLogs, variables["resource_name_prefix"])

	groupName := getGroupName(variables["resource_name_prefix"])
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
		_, err := cloudwatchLogs.PutLogEvents(&input)
		if err != nil {
			log.Fatal(err)
		}

		sleepTime := 30 * time.Second
		log.Println("\tSleeping ", sleepTime, "...")
		time.Sleep(sleepTime)

		log.Println()
	}
}
