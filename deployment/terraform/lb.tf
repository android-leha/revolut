resource "aws_lb" "miro-alb" {
  name = "miro-alb"
  internal = false

  ip_address_type = "ipv4"
  load_balancer_type = "application"



  security_groups = [
    aws_security_group.miro-alb-sg.id,
  ]
  subnets = aws_subnet.miro-lb[*].id
}

resource "aws_acm_certificate" "miro-lb-cert" {
  domain_name = var.domain
  validation_method = "EMAIL"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_lb_listener_certificate" "example" {
  listener_arn = aws_lb_listener.miro-alb-listener.arn
  certificate_arn = aws_acm_certificate.miro-lb-cert.arn
}


resource "aws_security_group" "miro-alb-sg" {
  name = "miro-alb-sg"
  vpc_id = aws_vpc.miro.id
}


resource "aws_lb_target_group" "miro-cluster" {

  name = "miro"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.miro.id

  health_check {
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }

}


resource "aws_lb_listener" "miro-alb-listener" {
  load_balancer_arn = aws_lb.miro-alb.arn
  port = 443
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.miro-cluster.arn
  }
}


resource "aws_security_group_rule" "inbound_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.miro-alb-sg.id
  cidr_blocks = [
    "0.0.0.0/0"]
}

