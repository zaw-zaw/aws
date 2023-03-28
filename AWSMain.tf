terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
provider "aws" {
  region = "ap-southeast-1"
}

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
    Name = "Webzone IGW"
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_network_interface" "Web01-int" {
  subnet_id = aws_subnet.Web-PubSubnet.id
  private_ips = ["10.144.10.5"]
  security_groups = [ data.aws_security_group.web-sg.id ]
  tags = {
    Name = "Piravte Interface for Web01 Server"
  }
}

resource "aws_instance" "Web01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "27032023"
 # associate_public_ip_address = true
  network_interface {
    network_interface_id = aws_network_interface.Web01-int.id
    device_index = 0

  }
  
  tags = {
    Name = "Prod Web Server"
  }
}

resource "aws_network_interface" "DB01-int" {
  subnet_id = aws_subnet.DB-PrivSubnet.id
  private_ips = ["172.16.10.55"]
  security_groups = [ data.aws_security_group.db-sg.id ]
  tags = {
    Name = "Piravte Interface for DB01 Server"
  }
}
resource "aws_instance" "DB01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "27032023"
 # associate_public_ip_address = false
  network_interface {
    network_interface_id = aws_network_interface.DB01-int.id
    device_index = 0

  }
  
  tags = {
    Nam = "Prod DB Server"
  }
}

resource "aws_network_interface" "Bastion01-int" {
  subnet_id = aws_subnet.Bastion-PubSubnet.id
  private_ips = [ "192.168.10.5" ]

  tags = {
    Name = "Piravte Interface for Bastion01 Server"
  }
}
resource "aws_instance" "Bastion01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "27032023"
  #associate_public_ip_address = false
  network_interface {
    network_interface_id = aws_network_interface.Bastion01-int.id
    device_index = 0

  }


  tags = {
    Name = "Prod Bastion Server"
  }
}

resource "aws_eip" "NAT-PubIP" {
  vpc = true
  tags = {
    Name = "Public IP for NAT GW"
  }
}

resource "aws_nat_gateway" "NAT-GW" {
    allocation_id = aws_eip.NAT-PubIP.id
    subnet_id = aws_subnet.DB-PubSubnet.id

    tags = {
      Name = "DB Server NAT GW"
    }
    depends_on = [
      aws_internet_gateway.DBZone-IGW
    ]
}

#Internet Gateway routing table for webzone
data "aws_route_table" "WebZone-RT" {
  vpc_id = aws_vpc.WebZone-VPC.id
}

resource "aws_route" "WebZone-Route" {
  route_table_id            = data.aws_route_table.WebZone-RT.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.WebZone-IGW.id
}

resource "aws_route" "WebToBastion-RT" {
  route_table_id = data.aws_route_table.WebZone-RT.id
  destination_cidr_block = aws_subnet.Bastion-PubSubnet.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.BastionToWeb-Peer.id
}

resource "aws_route" "WebToDB-RT" {
  route_table_id = data.aws_route_table.WebZone-RT.id
  destination_cidr_block = aws_subnet.DB-PrivSubnet.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.WebToDB-Peer.id
  
}

###Internet Gateway routing table for BastionZone
data "aws_route_table" "BastionZone-RT" {
  vpc_id = aws_vpc.BastionZone-VPC.id
}

resource "aws_route" "BastionZone-Route" {
  route_table_id            = data.aws_route_table.BastionZone-RT.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.BastionZone-IGW.id
}

resource "aws_route" "BastionToWeb-RT" {
  route_table_id = data.aws_route_table.BastionZone-RT.id
  destination_cidr_block = aws_subnet.Web-PubSubnet.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.BastionToWeb-Peer.id
}

resource "aws_route" "BastionToDB-RT" {
  route_table_id = data.aws_route_table.BastionZone-RT.id
  destination_cidr_block = aws_subnet.DB-PrivSubnet.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.BastionToDB-Peer.id
  
}

###Routing table for NAT Gateway
data "aws_route_table" "DBZone-RT" {
    #subnet_id = aws_subnet.DB-PubSubnet.id
    subnet_id = aws_vpc.DBZone-VPC.id
}

resource "aws_route" "DBZone-PublicRoute" {
  route_table_id            = data.aws_route_table.DBZone-RT.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.DBZone-IGW.id
}

resource "aws_route" "DBToWeb-RT" {
    route_table_id = aws_route_table.DBZone-PrivateRoute.id
    destination_cidr_block = aws_subnet.Web-PubSubnet.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.WebToDB-Peer.id
}

resource "aws_route" "DBToBastion" {
  route_table_id = aws_route_table.DBZone-PrivateRoute.id
  destination_cidr_block = aws_subnet.Bastion-PubSubnet.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.BastionToDB-Peer.id
}

resource "aws_route_table_association" "DBPublicSubnet-IGWRoute" {
  subnet_id = aws_subnet.DB-PubSubnet.id
  route_table_id = data.aws_route_table.DBZone-RT.id
}

resource "aws_route_table" "DBZone-PrivateRoute" {
  vpc_id = aws_vpc.DBZone-VPC.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW.id
  }
  
  tags = {
    Name = "Private subnet routing table from NAT Gateway"
  }
}

resource "aws_route_table_association" "DBPrivateSubnet-PrivateRoute" {
  subnet_id = aws_subnet.DB-PrivSubnet.id
  route_table_id = aws_route_table.DBZone-PrivateRoute.id
}

data "aws_security_group" "web-sg" {
    vpc_id = aws_vpc.WebZone-VPC.id
}

resource "aws_vpc_security_group_ingress_rule" "WebAllowSSH" {
    security_group_id = data.aws_security_group.web-sg.id
    cidr_ipv4   = "192.168.10.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
}

data "aws_security_group" "db-sg" {
    vpc_id = aws_vpc.DBZone-VPC.id
}

resource "aws_vpc_security_group_ingress_rule" "DBAllowSSH" {
    security_group_id = data.aws_security_group.db-sg.id
    cidr_ipv4   = "192.168.10.0/27"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
}

data "aws_security_group" "bastion-sg" {
    vpc_id = aws_vpc.BastionZone-VPC.id
}

resource "aws_vpc_security_group_ingress_rule" "BastionAllowSSH" {
    security_group_id = data.aws_security_group.db-sg.id
    cidr_ipv4   = "10.16.10.0/24"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
}

resource "aws_vpc_peering_connection" "BastionToWeb-Peer" {
  peer_vpc_id = aws_vpc.WebZone-VPC.id
  vpc_id = aws_vpc.BastionZone-VPC.id
  auto_accept = true
  
  tags = {
    Name = "Bastion to web vpc peering"
  }
}

resource "aws_vpc_peering_connection" "BastionToDB-Peer" {
  peer_vpc_id = aws_vpc.DBZone-VPC.id
  vpc_id = aws_vpc.BastionZone-VPC.id
  auto_accept = true
  
  tags = {
    Name = "Bastion to DB vpc peering"
  }
}

resource "aws_vpc_peering_connection" "WebToDB-Peer" {
  peer_vpc_id = aws_vpc.DBZone-VPC.id
  vpc_id = aws_vpc.WebZone-VPC.id
  auto_accept = true
  
  tags = {
    Name = "Web to DB vpc peering"
  }
}
