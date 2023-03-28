###Creating WebZone-VPC and Subnet
resource "aws_vpc" "WebZone-VPC" {
  cidr_block       = "10.144.10.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "WebZone-VPC"
  }
}

resource "aws_subnet" "Web-PubSubnet" {
  vpc_id     = aws_vpc.WebZone-VPC.id
  cidr_block = "10.144.10.0/27"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Web-Subnet"
  }
}

##Creating IGW for WebZone-VPC
resource "aws_internet_gateway" "WebZone-IGW" {
  vpc_id = aws_vpc.WebZone-VPC.id

  tags = {
    Name = "WebZone IGW"
  }
}

###Creating DBZone-VPC
resource "aws_vpc" "DBZone-VPC" {
  cidr_block       = "172.16.10.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "DBZone-VPC"
  }
}

resource "aws_subnet" "DB-PubSubnet" {
  vpc_id = aws_vpc.DBZone-VPC.id
  cidr_block = "172.16.10.0/27"

  tags = {
    Name = "Public DB-Subnet"
  }
}

resource "aws_subnet" "DB-PrivSubnet" {
  vpc_id = aws_vpc.DBZone-VPC.id
  cidr_block = "172.16.10.32/27"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Private DB-Subnet"
  }
}

##Creating IGW for DB-VPC
resource "aws_internet_gateway" "DBZone-IGW" {
  vpc_id = aws_vpc.DBZone-VPC.id

  tags = {
    Name = "DBZone IGW"
  }
}

###Creating BastionZone-VPC
resource "aws_vpc" "BastionZone-VPC" {
  cidr_block       = "192.168.10.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "BastionZone-VPC"
  }
}

resource "aws_subnet" "Bastion-PubSubnet" {
  vpc_id = aws_vpc.BastionZone-VPC.id
  cidr_block = "192.168.10.0/27"

  tags = {
    Name = "Public Bastion-Subnet"
  }
}

##Creating IGW for Bastion-VPC
resource "aws_internet_gateway" "BastionZone-IGW" {
  vpc_id = aws_vpc.BastionZone-VPC.id
  
  tags = {
    Name = "BastionZone IGW"
  }
}

