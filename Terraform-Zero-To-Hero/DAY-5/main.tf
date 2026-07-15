resource "aws_key_pair" "example" {
  key_name = "demo-key"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}

resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"  
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.name.id
}

resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.name.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }  
}

resource "aws_route_table_association" "public_1" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route.id
  
}

resource "aws_security_group" "sg" {
  name = "web"
  vpc_id = aws_vpc.name.id
  ingress {
    description = "Http From Vpc"
    from_port = 5050
    to_port = 5050
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Harish-sg"
  }
}

resource "aws_instance" "name" {
    ami = "ami-05d2d839d4f73aafb"
    instance_type = "t3.micro"
    key_name = aws_key_pair.example.key_name
    vpc_security_group_ids = aws_security_group.sg.id
    subnet_id = aws_subnet.public_subnet.id

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(pathexpand("~/.ssh/id_ed25519"))
      host = self.public_ip
    }

    provisioner "file" {
      source = "app.py"
      destination = "/home/ubuntu/app.py"       
    }
  
   provisioner "remote-exec" {
  inline = [
    "echo 'Hello from the remote instance'",
    "sudo apt update -y",
    "sudo apt install -y python3-pip",
    "pip3 install flask",
    "cd /home/ubuntu",
    "nohup python3 app.py > app.log 2>&1 &"
      ]
   }
}

output "public_ip" {
  value = aws_instance.name.public_ip  
}
