resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/20"
  tags = {
    Name = "${var.resource_name_prefix}-vpc"
  }
}