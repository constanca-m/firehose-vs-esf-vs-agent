output "firehose_arn" {
  description = "Firehose ARN of the resource created by this module"
  value       = aws_kinesis_firehose_delivery_stream.firehose_delivery_stream.arn
}

output "firehose_delivery_stream_name" {
  description = "Firehose delivery stream name"
  value       = aws_kinesis_firehose_delivery_stream.firehose_delivery_stream.name
}