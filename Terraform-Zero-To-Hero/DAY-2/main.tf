resource "aws_instance" "this" {
  ami              = var.ami[var.Environment]
  instance_type    = var.instance_type[var.Environment]
  subnet_id        = var.subnet_id[var.Environment]
  tags = {
    Name = "Harish"
  }
}

