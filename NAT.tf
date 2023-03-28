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
