
# Deploy the necessary resources to use firehose
module "firehose_requirements" {
  source               = "./requirements/firehose"
  resource_name_prefix = var.resource_name_prefix
  es_access_key        = var.es_access_key
  es_url               = var.es_url
  datastream_name      = "logs-firehose_workflow${var.test_workflow}-default"
}

# Create a cloudfront distribution and S3 bucket to be used in workflow 1
module "cloudfront_distribution" {
  source = "./workflow-1"

  # Create only if to test workflow 1
  count = var.test_workflow == 1 ? 1 : 0

  resource_name_prefix = var.resource_name_prefix
  firehose_arn         = module.firehose_requirements.firehose_arn

  depends_on = [module.firehose_requirements]
}


# Create a cloudwatch logs group to be used in workflow 2
module "cloudwatch_logs_group" {
  source = "./workflow-2"

  # Create only if to test workflow 2
  count = var.test_workflow == 2 ? 1 : 0

  aws_region           = var.aws_region
  firehose_arn         = module.firehose_requirements.firehose_arn
  resource_name_prefix = var.resource_name_prefix

  depends_on = [module.firehose_requirements]
}


# Create necessary resources for workflow 3
module "network_firewall_logs" {
  source = "./workflow-3"

  # Create only if to test workflow 3
  count = var.test_workflow == 3 ? 1 : 0

  resource_name_prefix          = var.resource_name_prefix
  firehose_delivery_stream_name = module.firehose_requirements.firehose_delivery_stream_name
  depends_on                    = [module.firehose_requirements]
}