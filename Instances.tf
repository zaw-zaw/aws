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





