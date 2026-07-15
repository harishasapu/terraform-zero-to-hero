resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="my_vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true

    tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-south-1a"

    tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "ap-south-1b"
    tags = {
    Name = "private-subnet-2"
  }
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

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
  tags = {
    Name = "eip-1"
  }
}

resource "aws_eip" "nat_eip_2" {
  domain = "vpc" 
  tags = {
    Name = "eip-2"
  } 
}

resource "aws_nat_gateway" "nat_1" {
    subnet_id = aws_subnet.public_subnet_1.id
    allocation_id = aws_eip.nat_eip_1.id
    tags = {
    Name = "nat-1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  allocation_id = aws_eip.nat_eip_2.id
  tags = {
    Name = "nat-2"
  }
}

resource "aws_route_table" "private_route_1" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }
  tags = {
    Name = "private-route-table-1"
  }
}

resource "aws_route_table_association" "private_1" {
    subnet_id = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_route_1.id
  
}

resource "aws_route_table" "private_route_2" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }
  tags = {
    Name = "private-route-table-2"
  } 
}

resource "aws_route_table_association" "private_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_2.id  
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb_sg.id
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_out" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0" 
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "ec2-sg"
  }  
}

resource "aws_vpc_security_group_ingress_rule" "ec2_http_ingress_from_alb" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
  cidr_ipv4 = aws_vpc.my_vpc.cidr_block
}

resource "aws_vpc_security_group_egress_rule" "ec2_egress" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = aws_vpc.my_vpc.cidr_block  
}