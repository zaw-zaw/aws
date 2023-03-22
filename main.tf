terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "latest"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  cloud {
    organization = "1212-zzl"
    workspaces {
      name = "aws-git-automate"
    }
  }
}

variable "ami" {
    type = string
    default = "ami-051f0947e420652a9"
}

variable "instance_types" {
    type = string
    default = "t2.micro"
}

variable "key_name" {
    type = string
    default = "SingtelZZL"
}

variable "bistion_subnet_id" {
    type = string
    default = "subnet-0f609bf5c2250218e"
}

variable "web01_subnet_id" {
    type = string
    default = "subnet-0544c78e4cd7093ec"
}

variable "bastion_security_group_id" {
    type = string
    default = "sg-0f16e76155fd76907"
}

variable "web01_security_group_id" {
    type = string
    default = "sg-0f299308e2012bc2c"
}

resource "aws_instance" "Bastion" {
  ami           = var.ami
  instance_type = var.instance_types
  key_name = var.key_name
  subnet_id = var.bistion_subnet_id 
  associate_public_ip_address = "true"
}

data "aws_security_group" "bastion_sg" {
 id = var.bastion_security_group_id
}  

output "bastion_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.Bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.Bastion.public_ip
}

output "bastion_private_ip" {
  description = "Pirvate IP address of the EC2 instance"
  value       = aws_instance.Bastion.private_ip
}
