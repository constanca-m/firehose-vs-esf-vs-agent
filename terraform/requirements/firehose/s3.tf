# Firehose S3 backup bucket

resource "aws_s3_bucket" "s3_bucket_firehose" {
  bucket        = "${var.resource_name_prefix}-bucket"
  force_destroy = true
}