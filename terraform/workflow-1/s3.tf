
# S3 bucket for cloudfront origin

resource "aws_s3_bucket" "s3_bucket_cloudfront_origin" {
  bucket        = "${var.resource_name_prefix}-cloudfront-origin"
  force_destroy = true
}

# Create a sample file and upload it in the bucket
locals {
  sample_file = yamlencode({ "origin" : "S3 bucket", "message" : "Some test message." })
}

resource "aws_s3_object" "s3_origin_sample_file" {
  bucket  = aws_s3_bucket.s3_bucket_cloudfront_origin.bucket
  key     = "sample.yaml"
  content = local.sample_file
}


data "aws_iam_policy_document" "s3_cloudfront_origin_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.s3_bucket_cloudfront_origin.arn,
      "${aws_s3_bucket.s3_bucket_cloudfront_origin.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_cloudfront_origin_policy" {
  bucket = aws_s3_bucket.s3_bucket_cloudfront_origin.id
  policy = data.aws_iam_policy_document.s3_cloudfront_origin_policy_document.json
}



# S3 bucket for cloudfront logs

resource "aws_s3_bucket" "s3_bucket_cloudfront_logs" {
  bucket        = "${var.resource_name_prefix}-cloudfront-logs"
  force_destroy = true
}

data "aws_iam_policy_document" "s3_cloudfront_logs_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl",

      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.s3_bucket_cloudfront_logs.arn,
      "${aws_s3_bucket.s3_bucket_cloudfront_logs.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_cloudfront_logs_policy" {
  bucket = aws_s3_bucket.s3_bucket_cloudfront_logs.id
  policy = data.aws_iam_policy_document.s3_cloudfront_logs_policy_document.json
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs_controls" {
  bucket = aws_s3_bucket.s3_bucket_cloudfront_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


# Associate S3 logs notification with lambda function
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_bucket_cloudfront_logs.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
