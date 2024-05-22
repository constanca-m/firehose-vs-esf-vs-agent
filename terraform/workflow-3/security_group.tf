resource "aws_security_group" "security_group" {
  name        = "${var.resource_name_prefix}-security-group"
  description = "Allow inbound SSH traffic on port 22"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ssh" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol       = "tcp"
  to_port           = 22
  from_port         = 22
  cidr_ipv4         = "0.0.0.0/0"
}

# resource "aws_vpc_security_group_ingress_rule" "ingress_rule_http" {
#   security_group_id = aws_security_group.security_group.id
#   ip_protocol       = "tcp"
#   to_port           = 80
#   from_port         = 80
#   cidr_ipv4         = "0.0.0.0/0"
# }
#
# resource "aws_vpc_security_group_ingress_rule" "ingress_rule_https" {
#   security_group_id = aws_security_group.security_group.id
#   ip_protocol       = "tcp"
#   to_port           = 443
#   from_port         = 443
#   cidr_ipv4         = "0.0.0.0/0"
# }

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}