resource "aws_security_group" "security_group" {
  name        = "${var.resource_name_prefix}-security-group"
  description = "Allow inbound SSH traffic on port 22"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol       = 6
  to_port           = 22
  from_port         = 22
  cidr_ipv4         = "0.0.0.0/0"
}