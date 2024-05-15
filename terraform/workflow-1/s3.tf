# S3 bucket for cloudfront origin
resource "aws_s3_bucket" "s3_bucket_cloudfront_origin" {
  bucket        = "${var.resource_name_prefix}-cloudfront-origin"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.s3_bucket_cloudfront_origin.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Create a sample file and upload it in the bucket - we later use this file to make requests and generate logs
locals {
  sample_file = yamlencode({ "origin" : "S3 bucket", "message" : "Some test message." })
}

resource "aws_s3_object" "s3_origin_sample_file" {
  bucket  = aws_s3_bucket.s3_bucket_cloudfront_origin.bucket
  key     = "sample.yaml"
  content = local.sample_file
}

# S3 bucket for cloudfront logs
resource "aws_s3_bucket" "s3_bucket_cloudfront_logs" {
  bucket        = "${var.resource_name_prefix}-cloudfront-logs"
  force_destroy = true
}

# Cloudfront needs this
resource "aws_s3_bucket_ownership_controls" "cloudfront_logs_controls" {
  bucket = aws_s3_bucket.s3_bucket_cloudfront_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Associate S3 logs notification with lambda function
#resource "aws_s3_bucket_notification" "bucket_notification_lambda" {
#  bucket = aws_s3_bucket.s3_bucket_cloudfront_logs.id
#
#  lambda_function {
#    lambda_function_arn = aws_lambda_function.function.arn
#    events              = ["s3:ObjectCreated:*"]
#    filter_suffix       = ".gz"
#  }
#
#  depends_on = [aws_lambda_permission.allow_bucket]
#}

# Associate S3 logs notification with queue
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_bucket_cloudfront_logs.id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".gz"
  }
}
