variable "resource_name_prefix" {
  description = "Prefix for each resource name created from the configuration files"
  type        = string
}

variable "firehose_arn" {
  description = "Firehose ARN to use for lambda permissions"
  type        = string
}

variable "create_firehose" {
  description = "If 1, necessary resources for firehose will be deployed. If 0, they will not be deployed, but ESF will."
  type        = number
}