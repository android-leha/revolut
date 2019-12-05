

resource "aws_vpc" "revolut" {
  cidr_block = "10.0.0.0/16"
  default = true
  tags = map(
    "Name", "eks-revolut-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "revolut" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.revolut.id

  tags = map(
    "Name", "eks-revolut-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "revolut" {
  vpc_id = aws_vpc.revolut.id

  tags = {
    Name = "eks-revolut"
  }
}

resource "aws_route_table" "revolut" {
  vpc_id = aws_vpc.revolut.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.revolut.id
  }
}

resource "aws_route_table_association" "revolut" {
  count = 2

  subnet_id      = aws_subnet.revolut.*.id[count.index]
  route_table_id = aws_route_table.revolut.id
}
