variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for each resource name created from the configuration files"
  type        = string
}

variable "datastream_name" {
  description = "Datastream name used by Firehose"
  type        = string
  default     = "logs-aws.cloudwatch_logs-default"
}

variable "es_url" {
  description = "Elasticsearch endpoint URL"
  type        = string
}

variable "es_access_key" {
  description = "Elasticsearch access key"
  type        = string
}
