locals {
  s3_origin_id = "myS3Origin"
}


resource "aws_cloudfront_distribution" "cloudfront" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.s3_bucket_cloudfront_origin.bucket_domain_name
    origin_id   = local.s3_origin_id
  }

  logging_config {
    bucket = aws_s3_bucket.s3_bucket_cloudfront_logs.bucket_domain_name
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}