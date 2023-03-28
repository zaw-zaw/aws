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