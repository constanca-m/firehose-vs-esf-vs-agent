output "s3_config_bucket_arn" {
  description = "S3 config bucket ARN"
  value       = aws_s3_bucket.s3_bucket_esf.arn
}