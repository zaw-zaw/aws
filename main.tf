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

resource "aws_instance" "Bastion" {
  ami           = "ami-051f0947e420652a9"
  instance_type = "t2.micro"
  key_name = "SingtelZZL"
  subnet_id = "subnet-0f609bf5c2250218e"
  associate_public_ip_address = "true"
}
output "bastion_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.Bastion.public_ip
}
