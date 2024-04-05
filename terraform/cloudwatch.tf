# Cloudwatch group that will have a subscription to the firehose delivery stream

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "${var.resource_name_prefix}-cloudwatch-lg"
}

data "aws_iam_policy_document" "cloudwatch_policy_document" {
  statement {
    effect = "Allow"

    actions = ["firehose:*"]

    resources = [aws_kinesis_firehose_delivery_stream.firehose_delivery_stream.arn]
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
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose_delivery_stream.arn
  filter_pattern  = ""
  log_group_name  = aws_cloudwatch_log_group.cloudwatch_log_group.name
  name            = "${var.resource_name_prefix}-cloudwatch-subscription"
  role_arn        = aws_iam_role.cloudwatch_role.arn
}

# Cloudwatch group for firehose error logging
# The group has two streams, one for S3 errors and another for endpoint errors

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_errors" {
  name = "${var.resource_name_prefix}-cloudwatch-lg-errors"
}

resource "aws_cloudwatch_log_stream" "cloudwatch_s3_errors" {
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group_errors.name
  name           = "${var.resource_name_prefix}-stream-s3"
}

resource "aws_cloudwatch_log_stream" "cloudwatch_endpoint_errors" {
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group_errors.name
  name           = "${var.resource_name_prefix}-stream-endpoint"
}
