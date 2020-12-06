data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

resource "aws_key_pair" "admin" {
  key_name = "admin"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "lb" {
  ami = var.image
  instance_type = "t2.micro"

  subnet_id = aws_subnet.miro-lb.id

  associate_public_ip_address = true

  key_name = aws_key_pair.admin.key_name

  vpc_security_group_ids = [
    aws_security_group.lb_sg.id,
  ]
  tags = {
    Name = "Load Balancer Server"
  }
}

resource "aws_security_group" "lb_sg" {

  vpc_id = aws_vpc.miro.id

  name = "lb_sg"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [
      local.workstation-external-cidr]
  }

  ingress {
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = [
      local.workstation-external-cidr,
    ]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [
      "0.0.0.0/0",
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

resource "aws_security_group" "jump_sg" {
  vpc_id = aws_vpc.miro.id
  name = "jump_sg"
  description = "Security group to allow ssh connection from jump"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [
      "${aws_instance.lb.private_ip}/32",
    ]
  }
}

