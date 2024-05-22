# Internet gateway route table
resource "aws_route_table" "route_table_internet" {
  vpc_id = aws_vpc.vpc.id

  // directs traffic that's bound for the customer subnet to the firewall endpoint.
  route {
    cidr_block      = aws_subnet.ec2_subnet.cidr_block
    vpc_endpoint_id = data.aws_vpc_endpoint.endpoint.id
  }

  // directs traffic that's bound for any destination inside the VPC to the destination specification local
  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "route_table_association_internet" {
  gateway_id     = aws_internet_gateway.internet_gateway.id
  route_table_id = aws_route_table.route_table_internet.id
}

# EC2 route table
resource "aws_route_table" "route_table_ec2" {
  vpc_id = aws_vpc.vpc.id

  #  directs internet-bound traffic to the firewall endpoint.
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = data.aws_vpc_endpoint.endpoint.id
  }

  // directs traffic that's bound for any destination inside the VPC to the destination specification local
  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "route_table_association_ec2" {
  subnet_id      = aws_subnet.ec2_subnet.id
  route_table_id = aws_route_table.route_table_ec2.id
}

# Firewall route table
resource "aws_route_table" "route_table_firewall" {
  vpc_id = aws_vpc.vpc.id

  // direct internet-bound traffic to the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  // directs traffic that's bound for any destination inside the VPC to the destination specification local
  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "route_table_association_firewall" {
  subnet_id      = aws_subnet.firewall_subnet.id
  route_table_id = aws_route_table.route_table_firewall.id
}
