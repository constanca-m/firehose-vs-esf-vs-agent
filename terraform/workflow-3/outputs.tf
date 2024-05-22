output "firewall_logs_group_arn" {
  description = "Cloudwatch logs group ARN"
  value       = var.create_firehose == 0 ? aws_cloudwatch_log_group.firewall_log_group[0].arn : ""
}