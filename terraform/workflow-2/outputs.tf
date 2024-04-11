output "cloudwatch_logs_group_arn" {
  description = "Cloudwatch logs group ARN"
  value       = aws_cloudwatch_log_group.cloudwatch_log_group.arn
}