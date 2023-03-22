# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "1212-zzl"

    workspaces {
      name = "aws-git-automate"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "random_pet" "sg" {}

resource "aws_instance" "web" {
  ami                    = "ami-051f0947e420652a9"
  instance_type          = "t2.micro"
  key_name = "SingtelZZL"
  subnet_id = "subnet-0f609bf5c2250218e"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}

output "web_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

