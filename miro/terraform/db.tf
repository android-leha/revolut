resource "aws_instance" "db" {
  ami = var.image
  instance_type = "t2.micro"

  subnet_id = aws_subnet.miro-db.id


  key_name = aws_key_pair.admin.key_name
  vpc_security_group_ids = [
    aws_security_group.db_sg.id,
    aws_security_group.jump_sg.id,
  ]
  tags = {
    Name = "Database Server"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.miro.id

  name = "db_sg"

  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [
      aws_vpc.miro.cidr_block,
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}