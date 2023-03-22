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

resource "aws_instance" "Bastion" {
  ami           = "ami-051f0947e420652a9"
  instance_type = "t2.micro"
  key_name = "SingtelZZL"
  subnet_id = "subnet-0f609bf5c2250218e"
  associate_public_ip_address = "true"
}

data "aws_security_group" "bastion_sg" {
 id = "sg-0f16e76155fd76907"
}  
