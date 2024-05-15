#!/bin/bash
#
# Setup a directory in this repository with ESF terraform files.

DOWNLOAD=${1}
ESF_GIT_REPOSITORY=${2}
ESF_LOCAL_DIRECTORY=${3}

ESF_DESTINATION_DIRECTORY="terraform/requirements/esf"
mkdir "${ESF_DESTINATION_DIRECTORY}"
cd "${ESF_DESTINATION_DIRECTORY}" || exit

if [[ ${DOWNLOAD} == "true" ]]; then
  echo "Repository ${ESF_GIT_REPOSITORY} will be cloned and placed in ${ESF_DESTINATION_DIRECTORY} directory."
  gh repo clone "${ESF_GIT_REPOSITORY}"
else
  echo "Directory ${ESF_LOCAL_DIRECTORY} will be copied and placed in ${ESF_DESTINATION_DIRECTORY} directory."
  cp "${ESF_LOCAL_DIRECTORY}"/*.tf .
fi

rm -f main.tf

cd ../../../terraform || exit

cat >> modules.tf <<EOF

# Deploy the necessary resources to use ESF
module "esf_requirements" {
  source = "./requirements/esf"

  lambda-name     = "\${var.resource_name_prefix}-esf"
  release-version = var.esf_release_version
  aws_region      = var.aws_region
  inputs = concat(
    [
      for cloudwatch-logs in module.cloudwatch_logs_group :
      {
        id : "\${cloudwatch-logs.cloudwatch_logs_group_arn}:*"
        type : "cloudwatch-logs"
        outputs = [
          {
            type = "elasticsearch"
            args = {
              elasticsearch_url  = var.es_url
              api_key            = var.es_access_key
              es_datastream_name = "logs-esf.cloudwatch-default"
            }
          }
        ]
      }
    ],
    [
      for cf in module.cloudfront_distribution :
      {
        id : cf.sqs_queue_notification_arn
        type : "s3-sqs"
        outputs = [
          {
            type = "elasticsearch"
            args = {
              elasticsearch_url  = var.es_url
              api_key            = var.es_access_key
              es_datastream_name = "logs-esf.s3_sqs-default"
            }
          }
        ]
      }
    ]
  )

  s3-buckets = [for cf in module.cloudfront_distribution : cf.s3_bucket_logs_arn]

  depends_on = [module.cloudwatch_logs_group, module.cloudfront_distribution]
}
# End ESF module
EOF
