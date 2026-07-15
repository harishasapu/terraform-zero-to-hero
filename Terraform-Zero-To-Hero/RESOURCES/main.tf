provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="my_vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"

    tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"

    tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "alb_sg"
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "ec2_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_ingress" {
  security_group_id = aws_security_group.alb_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
}


resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb_sg.id
  # from_port         = 0
  # to_port           = 0
  ip_protocol          = "-1"
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
}


resource "aws_vpc_security_group_ingress_rule" "ec2_http_ingress_from_alb" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol          = "tcp"
  cidr_ipv4 = aws_vpc.my_vpc.cidr_block
}


resource "aws_vpc_security_group_egress_rule" "ec2_egress" {
  security_group_id = aws_security_group.ec2_sg.id
  # from_port         = 0
  # to_port           = 0
  ip_protocol          = "-1"
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
}

resource "aws_lb" "alb" {
  name = "my-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "apk-load-balancer"
  }
}

resource "aws_lb_target_group" "tg" {
  name = "apk-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    interval = 30
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}

resource "aws_launch_template" "lt" {
  name_prefix = "apk-template"
  image_id = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  key_name = "awspemkey"
  network_interfaces {
    security_groups = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = false
  }

  tags = {
    Name = "apk-instance"
  }
}

resource "aws_autoscaling_group" "auto-scaling-grp" {
  launch_template {
    id = aws_launch_template.lt.id
  }
  
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id,aws_subnet.private_subnet_2.id]
  desired_capacity = 2
  max_size = 4
  min_size = 2

  target_group_arns = [aws_lb_target_group.tg.arn]

}

resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.nat_eip_1.id
  tags = {
    Name = "nat-1"
  }

}

resource "aws_route_table" "private_route_1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_1.id
}

resource "aws_eip" "nat_eip_2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  allocation_id = aws_eip.nat_eip_2.id
  tags = {
    Name = "nat-2"
  }

}

resource "aws_route_table" "private_route_2" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }

}


resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_2.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "main-igw"
  }

}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route.id
}

output "apk-load-balancer-dns" {
  value = aws_lb.alb.dns_name
}
