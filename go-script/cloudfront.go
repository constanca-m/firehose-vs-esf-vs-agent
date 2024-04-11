package main

import (
	"log"
	"net/http"
	"time"

	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudfront"
)

const sampleFile = "sample.yaml"

func getOriginDomainName() string {
	return variables["resource_name_prefix"] + "-cloudfront-origin.s3.amazonaws.com"
}

func getDistributionDomainName(cf *cloudfront.CloudFront) string {
	distributions, err := cf.ListDistributions(&cloudfront.ListDistributionsInput{})
	if err != nil {
		log.Fatal(err)
	}

	list := distributions.DistributionList
	for _, d := range list.Items {
		for _, origin := range d.Origins.Items {
			if *origin.DomainName == getOriginDomainName() {
				return *d.DomainName
			}
		}
	}
	log.Fatalf("Distribution with S3 origin %s does not exist.", getOriginDomainName())
	return ""
}

func produceCloudfrontLogs(sess *session.Session) {
	cf := cloudfront.New(sess)

	domainName := getDistributionDomainName(cf)
	url := "https://" + domainName + "/" + sampleFile

	client := &http.Client{}
	for {
		nRequests := 5
		log.Println("\tSending ", nRequests, " requests to ", url, "...")
		for i := 0; i < nRequests; i++ {
			request, err := http.NewRequest("GET", url, nil)
			if err != nil {
				log.Fatal(err)
			}
			// send the request
			_, _ = client.Do(request)
		}

		sleep := 5 * time.Minute
		log.Println("\tSleeping for ", sleep.String(), "...")
		time.Sleep(sleep)

		log.Println()
	}

}
