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
