resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "${var.resource_name_prefix}-firewall-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
  }
}

resource "aws_networkfirewall_firewall" "firewall" {
  firewall_policy_arn = aws_networkfirewall_firewall_policy.firewall_policy.arn
  name                = "${var.resource_name_prefix}-firewall"
  vpc_id              = aws_vpc.vpc.id
  subnet_mapping {
    subnet_id = aws_subnet.subnet.id
  }
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "${var.resource_name_prefix}-networkfirewall"
}

resource "aws_networkfirewall_logging_configuration" "logging" {
  firewall_arn = aws_networkfirewall_firewall.firewall.arn
  logging_configuration {
    log_destination_config {
      #log_destination = {
      #  deliveryStream = var.firehose_delivery_stream_name
      #}
      #log_destination_type = "KinesisDataFirehose"
      #log_type             = "FLOW"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.cloudwatch_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }

    log_destination_config {
      #log_destination = {
      #  deliveryStream = var.firehose_delivery_stream_name
      #}
      #log_destination_type = "KinesisDataFirehose"
      #log_type             = "FLOW"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.cloudwatch_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}