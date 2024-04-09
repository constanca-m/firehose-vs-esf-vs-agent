resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/20"
  tags = {
    Name = "${var.resource_name_prefix}-subnet"
  }
}