# Cloudwatch logs group that will receive the network firewall logs
resource "aws_cloudwatch_log_group" "firewall_log_group" {
  count = var.create_firehose == 0 ? 1 : 0

  name = "${var.resource_name_prefix}-network-firewall-logs"
}