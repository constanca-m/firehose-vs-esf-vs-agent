resource "aws_key_pair" "key_pair" {
  key_name   = "${var.resource_name_prefix}-key"
  public_key = file("${path.module}/key.pub")
}