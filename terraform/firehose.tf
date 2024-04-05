# Firehose delivery stream

data "aws_iam_policy_document" "firehose_policy_role_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "${var.resource_name_prefix}-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_policy_role_document.json
}

data "aws_iam_policy_document" "firehose_policy_permissions_document" {
  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.cloudwatch_log_group_errors.arn}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      aws_s3_bucket.s3_bucket_firehose.arn,
      "${aws_s3_bucket.s3_bucket_firehose.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "firehose_permissions_policy" {
  name   = "${var.resource_name_prefix}-firehose-policy"
  policy = data.aws_iam_policy_document.firehose_policy_permissions_document.json
}

resource "aws_iam_role_policy_attachment" "firehose_permissions" {
  policy_arn = aws_iam_policy.firehose_permissions_policy.arn
  role       = aws_iam_role.firehose_role.name
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_delivery_stream" {
  destination = "http_endpoint"
  name        = "${var.resource_name_prefix}-firehose-ds"

  http_endpoint_configuration {
    name       = "Elastic"
    url        = var.es_url
    access_key = var.es_access_key
    role_arn   = aws_iam_role.firehose_role.arn

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.cloudwatch_log_group_errors.name
      log_stream_name = aws_cloudwatch_log_stream.cloudwatch_endpoint_errors.name
    }

    request_configuration {
      content_encoding = "GZIP"

      common_attributes {
        name  = "es_datastream_name"
        value = var.datastream_name
      }
    }

    s3_configuration {
      role_arn   = aws_iam_role.firehose_role.arn
      bucket_arn = aws_s3_bucket.s3_bucket_firehose.arn

      cloudwatch_logging_options {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.cloudwatch_log_group_errors.name
        log_stream_name = aws_cloudwatch_log_stream.cloudwatch_s3_errors.name
      }
    }
  }
}