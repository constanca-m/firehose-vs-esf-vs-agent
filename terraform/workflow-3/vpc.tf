resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  #enable_dns_hostnames = true
  tags = {
    Name = "${var.resource_name_prefix}-vpc"
  }
}

data "aws_vpc_endpoint" "endpoint" {
  vpc_id = aws_vpc.vpc.id
  state  = "available"

  tags = {
    Firewall                  = aws_networkfirewall_firewall.firewall.arn
    AWSNetworkFirewallManaged = "true"
  }
}