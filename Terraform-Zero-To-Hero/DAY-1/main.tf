provider "aws" {
  region = "ap-south-1" 
}

resource "aws_instance" "this" {
  ami            = "ami-05d2d839d4f73aafb"
  instance_type  = "t3.micro"
  subnet_id      = "subnet-0a552a2324bfabae9"
  tags = {
    Name = "Harish"
  }
}


