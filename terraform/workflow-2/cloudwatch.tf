# Cloudwatch logs group that will receive the logs.
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "${var.resource_name_prefix}-cloudwatch-lg"
}

## Subscribe firehose
data "aws_iam_policy_document" "cloudwatch_policy_document" {
  count = var.create_firehose == 0 ? 0 : 1

  statement {
    effect = "Allow"

    actions = ["firehose:*"]

    resources = [var.firehose_arn]
  }
}

resource "aws_iam_policy" "cloudwatch_policy" {
  count = var.create_firehose == 0 ? 0 : 1

  name   = "${var.resource_name_prefix}-cloudwatch-policy"
  policy = data.aws_iam_policy_document.cloudwatch_policy_document[0].json
}

data "aws_iam_policy_document" "cloudwatch_role_document" {
  count = var.create_firehose == 0 ? 0 : 1

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
  count = var.create_firehose == 0 ? 0 : 1

  name               = "${var.resource_name_prefix}-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_role_document[0].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_role_policy" {
  count = var.create_firehose == 0 ? 0 : 1

  policy_arn = aws_iam_policy.cloudwatch_policy[0].arn
  role       = aws_iam_role.cloudwatch_role[0].name
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_subscription" {
  count = var.create_firehose == 0 ? 0 : 1

  destination_arn = var.firehose_arn
  filter_pattern  = ""
  log_group_name  = aws_cloudwatch_log_group.cloudwatch_log_group.name
  name            = "${var.resource_name_prefix}-cloudwatch-subscription"
  role_arn        = aws_iam_role.cloudwatch_role[0].arn
}


