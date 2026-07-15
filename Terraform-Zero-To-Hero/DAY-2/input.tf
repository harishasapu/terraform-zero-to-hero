variable "Environment" {
  type = string
  default = "dev"
}

variable "instance_type" {
   type = map(string)
  default = {
    prod = "t3.large"
    dev = "t3.small"
    qa = "t3.micro"
  }
}

variable "ami" {
  type = map(string)
  default = {
    prod = "ami-05d2d839d4f73aaf5"
    dev = "ami-05d2d839d4f73aau4"
    qa = "ami-05d2d839d4f73aa89"
  }  
}

variable "subnet_id" {
  type = map(string)
  default = {
    prod = "subnet-0a552a2324bfabae9"
    dev = "subnet-0a552a2324bfaba90"
    qa = "subnet-0a552a2324bfabae6h"
  }  
}