terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "Bitnami_LMS" {
  ami           = "ami-0bbdb939ba1170846"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.LMS_SG.id]

  tags = {
    Name = "Bitnami_LMS"
  }
}

resource "aws_security_group" "LMS_SG" {
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "LMS_SG"
    Project = "Bitnami_LMS"
  }
}

data "aws_vpc" "main" {
  id = var.vpc_id
}