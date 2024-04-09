# ESF S3 bucket settings

locals {
  # https://www.elastic.co/guide/en/esf/current/aws-deploy-elastic-serverless-forwarder.html#sample-s3-config-file
  esf_config_file_content = yamlencode({
    inputs : [
      {
        type : "cloudwatch-logs"
        id : var.cloudwatch_log_group_arn
        outputs : [
          {
            type : "elasticsearch"
            args : {
              elasticsearch_url : var.es_url
              api_key : var.es_access_key
              es_datastream_name : "logs-esf.test-default"
            }
          }
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "s3_bucket_esf" {
  bucket        = "${var.resource_name_prefix}-esf-bucket"
  force_destroy = true
}

# Upload the ESF YAML config to S3
resource "aws_s3_object" "esf-config-file-upload" {
  bucket  = aws_s3_bucket.s3_bucket_esf.bucket
  key     = "config.yaml"
  content = local.esf_config_file_content
}
