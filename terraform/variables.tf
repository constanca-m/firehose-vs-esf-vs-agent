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

variable "es_url" {
  description = "Elasticsearch endpoint URL"
  type        = string
}

variable "es_access_key" {
  description = "Elasticsearch access key"
  type        = string
}

variable "esf_release_version" {
  description = "ESF release version"
  type        = string
}

variable "test_workflow" {
  description = "Workflow to test"
  type        = number
}

variable "create_firehose" {
  description = "If 1, necessary resources for firehose will be deployed. If 0, they will not be deployed, but ESF will."
  type        = number
}


