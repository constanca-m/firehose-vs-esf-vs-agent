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

variable "cloudwatch_log_group_arn" {
  description = "Cloudwatch logs group ARN to be used for the input in the config.yaml file"
  type = string
}