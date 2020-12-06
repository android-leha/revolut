resource "aws_instance" "app" {
  count = 3

  ami = var.image

  instance_type = "t2.micro"

  subnet_id = aws_subnet.miro-app.id

  key_name = aws_key_pair.admin.key_name
  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
    aws_security_group.jump_sg.id,
  ]

  tags = {
    Name = "App server ${count.index}"
  }
}


resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.miro.id

  name = "app_sg"

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [
      aws_subnet.miro-lb.cidr_block,
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
