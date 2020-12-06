# VPC
resource "aws_vpc" "miro" {

  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "miro"
  }
}


# 3 Subnets: LB, App and DB
resource "aws_subnet" "miro-app" {
  availability_zone = local.az
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.miro.id

  tags = {
    Name = "Application"
    "kubernetes.io/cluster/eks-miro-cluster" = "shared"
  }
}

resource "aws_subnet" "miro-lb" {
  availability_zone = az
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.miro.id
  tags = {
    Name = "Load Balancer"
  }
}


resource "aws_subnet" "miro-db" {
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.miro.id
  tags = {
    Name = "Database"
  }
}


# Connect LB Subnet to Internet
resource "aws_internet_gateway" "miro-lb" {
  vpc_id = aws_vpc.miro.id
}

resource "aws_route_table" "miro-lb" {
  vpc_id = aws_vpc.miro.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.miro-lb.id
  }

  tags = {
    Name = "Load Balancer Route Table"
  }
}

resource "aws_route_table_association" "miro" {
  count = length(aws_subnet.miro-lb)
  subnet_id = aws_subnet.miro-lb[count.index].id
  route_table_id = aws_route_table.miro-lb.id
}

# Connect App Subnet to internet
resource "aws_eip" "miro-nat" {
  count = length(aws_subnet.miro-app)
}

resource "aws_nat_gateway" "miro-app" {
  count = length(aws_subnet.miro-app)
  allocation_id = aws_eip.miro-nat[count.index].id
  subnet_id = aws_subnet.miro-app[count.index].id
}

resource "aws_route_table" "miro-app" {
  vpc_id = aws_vpc.miro.id


  tags = {
    Name = "Application Route Table"
  }
}

resource "aws_route_table_association" "miro-app" {
  count = length(aws_subnet.miro-app)
  route_table_id = aws_route_table.miro-app.id
  subnet_id = aws_subnet.miro-app[count.index].id
}
