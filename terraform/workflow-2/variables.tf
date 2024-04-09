variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for each resource name created from the configuration files"
  type        = string
}

variable "firehose_arn" {
  description = "Firehose ARN to use for the cloudwatch logs group subscription"
  type        = string
}