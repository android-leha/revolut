# VPC
resource "aws_vpc" "miro" {

  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "miro"
  }
}

# Subnets
resource "aws_subnet" "miro-lb" {
  availability_zone = var.az
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.miro.id


  tags = {
    Name = "Load Balancer Subnet"
  }
}

resource "aws_subnet" "miro-app" {
  availability_zone = var.az
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.miro.id
  tags = {
    Name = "Application Subnet"
  }
}

resource "aws_subnet" "miro-db" {
  availability_zone = var.az
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.miro.id

  tags = {
    Name = "Database Subnet"
  }
}

# Connect public subnet to Internet
resource "aws_internet_gateway" "miro" {
  vpc_id = aws_vpc.miro.id
}

resource "aws_route_table" "miro-public" {
  vpc_id = aws_vpc.miro.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.miro.id
  }
}

resource "aws_route_table_association" "miro" {
  subnet_id = aws_subnet.miro-lb.id
  route_table_id = aws_route_table.miro-public.id
}

# Allow all egress and 22,80,5432 ingress traffic on network level
resource "aws_network_acl" "miro" {
  vpc_id = aws_vpc.miro.id

  subnet_ids = [
    aws_subnet.miro-lb.id,
    aws_subnet.miro-app.id,
    aws_subnet.miro-db.id,
  ]

  ingress {
    rule_no = 100
    protocol = "tcp"
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 22
    to_port = 22
  }

  ingress {
    rule_no = 200
    protocol = "tcp"
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  ingress {
    rule_no = 300
    protocol = "tcp"
    action = "allow"
    cidr_block = aws_subnet.miro-app.cidr_block
    from_port = 5432
    to_port = 5432
  }

  egress {
    rule_no = 100
    protocol = "-1"
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  tags = {
    Name = "Common Network ACL"
  }
}

# Connect private subnets to internet
resource "aws_eip" "miro" {

}

resource "aws_nat_gateway" "miro" {
  allocation_id = aws_eip.miro.id
  subnet_id = aws_subnet.miro-lb.id
}

resource "aws_route_table" "miro-private" {
  vpc_id = aws_vpc.miro.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.miro.id
  }
}

resource "aws_route_table_association" "miro-app" {
  subnet_id = aws_subnet.miro-app.id
  route_table_id = aws_route_table.miro-private.id
}

resource "aws_route_table_association" "miro-db" {
  subnet_id = aws_subnet.miro-db.id
  route_table_id = aws_route_table.miro-private.id
}



