# Cloudwatch logs group that will receive the logs. It will have two subscriptions:
# 1. One to be used by ESF.
# 2. The other one to be used by Firehose.

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "${var.resource_name_prefix}-cloudwatch-lg"
}


## Subscribe firehose

data "aws_iam_policy_document" "cloudwatch_policy_document" {
  statement {
    effect = "Allow"

    actions = ["firehose:*"]

    resources = [var.firehose_arn]
  }
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name   = "${var.resource_name_prefix}-cloudwatch-policy"
  policy = data.aws_iam_policy_document.cloudwatch_policy_document.json
}

data "aws_iam_policy_document" "cloudwatch_role_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  name               = "${var.resource_name_prefix}-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_role_document.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_role_policy" {
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
  role       = aws_iam_role.cloudwatch_role.name
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_subscription" {
  destination_arn = var.firehose_arn
  filter_pattern  = ""
  log_group_name  = aws_cloudwatch_log_group.cloudwatch_log_group.name
  name            = "${var.resource_name_prefix}-cloudwatch-subscription"
  role_arn        = aws_iam_role.cloudwatch_role.arn
}


