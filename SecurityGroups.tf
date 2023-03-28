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
