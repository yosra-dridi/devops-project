terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# connect with the cloud provider
provider "aws" {
  region = "us-east-2"
}

# create a vpc - with a particular cidr
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops"
  }
}

# create an internet gateway - to access internet and gain public ips
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops"
  }
}

# create a subnet - with a particular cidr , zone
resource "aws_subnet" "primary" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.primary_subnet_cidr

  tags = {
    Name = "primary"
  }
}

# a custom route table - vpc level (we also have main -vpc level -default inherited by subnet in absense of custom one)
resource "aws_route_table" "primary_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id # we are creating a public network / nat_gateway_id for a private network
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "primary-route-table"
  }
}

# associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.primary.id
  route_table_id = aws_route_table.primary_route_table.id
}

# security group - these act at an instance level
resource "aws_security_group" "web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins server"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Python server"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web"
  }
}

# # get virtual image id
# data "aws_ami" "amazon" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amazon*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["self", "amazon"] # I dont understand this
# }

# deployer's(mine) public key (ssh) to communicate with the instances
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("/home/yosra/.ssh/id_rsa.pub")
}

# instance for jenkins
resource "aws_instance" "jenkins" {
  ami                         = var.amazon_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.primary.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.deployer.id
  associate_public_ip_address = true
  root_block_device {
    volume_size = "10"
  }
  # user_data = file("initial_setup.sh")
  tags = {
    Name = "jenkins"
  }
}

# instance for the application
resource "aws_instance" "application" {
  ami                         = var.amazon_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.primary.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.deployer.id
  associate_public_ip_address = true
  root_block_device {
    volume_size = "10"
  }
  # user_data = file("initial_setup.sh")
  tags = {
    Name = "application"
  }
}
