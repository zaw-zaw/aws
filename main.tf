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

resource "aws_instance" "web" {
  ami                    = "ami-051f0947e420652a9"
  instance_type          = "t2.micro"
  associate_public_ip_address = "true"
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
