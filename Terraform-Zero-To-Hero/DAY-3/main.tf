provider "aws" {
  region = "ap-south-1"
}

module "ec2_instance" {
    source = "./modules/ec2_instance"
    ami = "ami-05d2d839d4f73aafb"
    instance_type = "t3.micro"
}

output "public_ip" {
  value = module.ec2_instance.public_ip  
}

output "instance_type" {
  value = module.ec2_instance.instance-type
}