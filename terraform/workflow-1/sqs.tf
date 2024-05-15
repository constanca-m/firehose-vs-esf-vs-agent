# SQS triggered by S3 notification

data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:${var.resource_name_prefix}-s3-event-notification-queue"]
  }
}

resource "aws_sqs_queue" "queue" {
  name   = "${var.resource_name_prefix}-s3-event-notification-queue"
  policy = data.aws_iam_policy_document.queue.json
}