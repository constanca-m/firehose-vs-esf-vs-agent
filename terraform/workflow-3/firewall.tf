resource "aws_networkfirewall_rule_group" "rule_group" {
  capacity = 100
  name     = "${var.resource_name_prefix}-rule-group"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = ["www.amazon.com", "amazon.com"]
      }
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "${var.resource_name_prefix}-firewall-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.rule_group.arn
    }
  }
}

resource "aws_networkfirewall_firewall" "firewall" {
  firewall_policy_arn = aws_networkfirewall_firewall_policy.firewall_policy.arn
  name                = "${var.resource_name_prefix}-firewall"
  vpc_id              = aws_vpc.vpc.id
  subnet_mapping {
    subnet_id = aws_subnet.firewall_subnet.id
  }

  //depends_on = [aws_iam_role_policy_attachment.network_firewall_permissions]
}

resource "aws_networkfirewall_logging_configuration" "logging" {
  firewall_arn = aws_networkfirewall_firewall.firewall.arn

  logging_configuration {
    log_destination_config {
      log_destination = var.create_firehose == 0 ? {
        //bucketName = aws_s3_bucket.firewall_logs_bucket[0].bucket
        logGroup = aws_cloudwatch_log_group.firewall_log_group[0].name
        } : {
        deliveryStream = var.firehose_delivery_stream_name
      }
      log_destination_type = var.create_firehose == 0 ? "CloudWatchLogs" : "KinesisDataFirehose"
      log_type             = "ALERT"
    }
  }
}

/*

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["network-firewall.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_network_firewall" {
  name               = "${var.resource_name_prefix}-network-firewall-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "logs_permissions_document" {
  count = var.create_firehose == 0 ? 1 : 0

  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroup",
      "logs:DescribeLogStreams"
    ]
    resources = ["${aws_cloudwatch_log_group.firewall_log_group[0].arn}:*"]
  }
}

data "aws_iam_policy_document" "firehose_permissions_document" {
  count = var.create_firehose

  statement {
    effect  = "Allow"
    actions = ["firehose:*"]
    resources = [var.firehose_arn]
  }
}

resource "aws_iam_policy" "network_firewall_permissions_policy" {
  name   = "${var.resource_name_prefix}-network-firewall-policy"
  policy = var.create_firehose == 1 ? (
    data.aws_iam_policy_document.firehose_permissions_document[0].json
  ) : data.aws_iam_policy_document.logs_permissions_document[0].json
}

resource "aws_iam_role_policy_attachment" "network_firewall_permissions" {
  policy_arn = aws_iam_policy.network_firewall_permissions_policy.arn
  role       = aws_iam_role.iam_for_network_firewall.name
}

*/