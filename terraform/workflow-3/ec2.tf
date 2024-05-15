# Lookup the ami, so we don't have to hardcode it according to the region
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security_group.id]

  tags = {
    "project" : "benchmarking-esf-firehose-ea"
    "team" : "obs-ds-hosted-services"
    "Name" : "${var.resource_name_prefix}-ec2"
    "division" : "engineering",
    "org" : "obs"
  }

  key_name = aws_key_pair.key_pair.key_name

  # From https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway:
  # It's recommended to denote that the AWS Instance or Elastic IP depends on the Internet Gateway.
  depends_on = [aws_internet_gateway.internet_gateway]
}