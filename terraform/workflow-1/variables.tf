variable "resource_name_prefix" {
  description = "Prefix for each resource name created from the configuration files"
  type        = string
}

variable "firehose_arn" {
  description = "Firehose ARN to use for lambda permissions"
  type        = string
}