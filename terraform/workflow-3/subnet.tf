resource "aws_subnet" "ec2_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "${var.resource_name_prefix}-ec2-subnet"
  }
}


resource "aws_subnet" "firewall_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "${var.resource_name_prefix}-firewall-subnet"
  }
}