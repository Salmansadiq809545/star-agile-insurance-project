terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}




# VPC creation 
resource "aws_vpc" "proj-vpc" {
  cidr_block = "10.0.0.0/16"
}


# Internet Gateway
resource "aws_internet_gateway" "proj-gt" {
  vpc_id = aws_vpc.proj-vpc.id

  tags = {
    Name = "main"
  }
}

# Route Table
resource "aws_route_table" "proj-rt" {
  vpc_id = aws_vpc.proj-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proj-gt.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.proj-gt.id
  }

  tags = {
    Name = "rt1"
  }
}

# Subnet 
resource "aws_subnet" "proj-subnet" {
  vpc_id     = aws_vpc.proj-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "subnet1"
  }
}

# Associate the Subnet with the Route Table
resource "aws_route_table_association" "proj-rt-sub-assoc" {
  subnet_id      = aws_subnet.proj-subnet.id
  route_table_id = aws_route_table.proj-rt.id
}


# Security Group Creation
resource "aws_security_group" "Proj-secg" {
  name        = "example-security-group"
  description = "Example security group allowing SSH, HTTP, and HTTPS traffic"
  vpc_id = aws_vpc.proj-vpc.id
  // Ingress rule allowing all traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Egress rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Inbound rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Allow traffic from any IPv4 address
  }

  // Inbound rule for HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Allow traffic from any IPv4 address
  }

  // Inbound rule for HTTPS (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Allow traffic from any IPv4 address
  }

  // Outbound rule allowing all traffic to leave the security group
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  // All protocols
    cidr_blocks = ["0.0.0.0/0"]  // Allow traffic to any IPv4 address
  }

  // Optionally, you can specify any other additional configuration here
}

# Network Group
resource "aws_network_interface" "proj-nt" {
  subnet_id       = aws_subnet.proj-subnet.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.Proj-secg.id]
}


# Elastic IP 
resource "aws_eip" "proj-eip" {
  vpc = true
  network_interface = aws_network_interface.proj-nt.id
  associate_with_private_ip = "10.0.1.10"
}

# Creating ec2 Instance
resource "aws_instance" "prod_server8095" {
  ami           = "ami-03bb6d83c60fc5f7c"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1b"
  key_name = "Tom"
  network_interface {
  device_index = 0
  network_interface_id = aws_network_interface.proj-nt.id
}
user_data = <<-EOF
#!/bin/bash
    sudo apt-get update -y
    sudo apt-get update -y
    sudo apt-get install docker.io -y
    sudo systemctl enable docker
    sudo docker stop C01
    sudo docker rm C01
    sudo docker run -itd -p 8084:8081 --name C01 salman8095/insuranceproject:v1
    sudo docker start $(docker ps -aq)
  EOF
  tags = {
    Name = "Salman-Prod-Server"
  }
}
