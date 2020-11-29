
resource "aws_vpc" "miro" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "miro"
  }
}

resource "aws_subnet" "miro-app" {
  count = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = "10.0.${count.index}.0/24"
  vpc_id = aws_vpc.miro.id

  tags = {
    Name = "Application"
    "kubernetes.io/cluster/eks-miro" = "shared"
  }


}

resource "aws_subnet" "miro-lb" {
  count = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = "10.0.${count.index + 63}.0/24"
  vpc_id = aws_vpc.miro.id
  tags = {
    Name = "Load Balancer"
  }
}


resource "aws_subnet" "miro-db" {
  count = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = "10.0.${count.index + 127}.0/24"
  vpc_id = aws_vpc.miro.id
  tags = {
    Name = "Database"
  }
}


resource "aws_internet_gateway" "miro" {
  vpc_id = aws_vpc.miro.id
}

resource "aws_route_table" "miro" {
  vpc_id = aws_vpc.miro.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.miro.id
  }

}


resource "aws_route_table_association" "miro" {
  count = 2
  subnet_id = aws_subnet.miro-lb[count.index].id
  route_table_id = aws_route_table.miro.id
}
