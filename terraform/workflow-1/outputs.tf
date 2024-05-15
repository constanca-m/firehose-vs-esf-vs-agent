output "sqs_queue_notification_arn" {
  description = "SQS queue ARN triggered by S3 object creation"
  value       = aws_sqs_queue.queue.arn
}

output "s3_bucket_logs_arn" {
  description = "S3 bucket ARN with the cloudfront logs"
  value       = aws_s3_bucket.s3_bucket_cloudfront_logs.arn
}