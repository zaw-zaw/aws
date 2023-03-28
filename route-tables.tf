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

resource "aws_route" "BastionToAzure" {
  route_table_id = data.aws_route_table.BastionZone-RT.id
  destination_cidr_block = "10.16.10.0/24"
  gateway_id = aws_vpn_connection.AWSAZS2S.id
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

