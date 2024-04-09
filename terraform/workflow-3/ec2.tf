
# EC2 needs an ami, but that changes according to the region. We will use data aws_ami so we don't have to hardcode it.
data "aws_ami" "ami_data" {
  # This is ubuntu image
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ami_data.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet.id

  tags = {
    "org"      = "obs"
    "division" = "engineering"
    "project"  = "benchmark-firehose-test"
    "Name"     = "${var.resource_name_prefix}-ec2"
    "team"     = "hosted-services"
  }
}