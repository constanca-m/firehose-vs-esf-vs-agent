
# Deploy the necessary resources to use firehose
module "firehose_requirements" {
  source = "./requirements/firehose"

  resource_name_prefix = var.resource_name_prefix
  es_access_key        = var.es_access_key
  es_url               = var.es_url

  datastream_name = "logs-firehose-default"
}

# Create a cloudfront distribution and S3 bucket to be used in workflow 1
module "cloudfront_distribution" {
  source = "./workflow-1"

  # Create only if 1 is present in test_workflows
  count = contains(var.test_workflows, 1) ? 1 : 0

  resource_name_prefix = var.resource_name_prefix

  depends_on = [module.firehose_requirements]
}

# Create a cloudwatch logs group to be used in workflow 2
module "cloudwatch_logs_group" {
  source = "./workflow-2"

  # Create only the cloudwatch logs group if workflow 2 is present in test_workflows
  count = contains(var.test_workflows, 2) ? 1 : 0

  aws_region           = var.aws_region
  firehose_arn         = module.firehose_requirements.firehose_arn
  resource_name_prefix = var.resource_name_prefix

  depends_on = [module.firehose_requirements]
}

# Deploy the necessary resources to use ESF
module "esf_requirements" {
  source = "./requirements/esf"

  # Change this to 1 if you also want to create the S3 bucket for ESF. Go to https://github.com/elastic/terraform-elastic-esf
  # for the ESF terraform files.
  count = 0

  resource_name_prefix     = var.resource_name_prefix
  cloudwatch_log_group_arn = "${module.cloudwatch_logs_group[0].cloudwatch_logs_group_arn}:*"
  es_access_key            = var.es_access_key
  es_url                   = var.es_url

  depends_on = [module.cloudwatch_logs_group]
}


# Create necessary resources for workflow 3
module "network_firewall_logs" {
  source = "./workflow-3"

  # Create only if workflow 3 is present in test_workflows
  count = contains(var.test_workflows, 3) ? 1 : 0

  depends_on                    = [module.firehose_requirements]
  resource_name_prefix          = var.resource_name_prefix
  firehose_delivery_stream_name = module.firehose_requirements.firehose_delivery_stream_name
}
