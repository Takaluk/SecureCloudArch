resource "aws_lb_target_group" "web_lb_tg" {
  name     = "web-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
  }

  health_check {
    path    = "/boot/"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "web_lb_tg_attach_11" {
  target_group_arn = aws_lb_target_group.web_lb_tg.arn
  target_id        = var.web11_ec2_id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "web_lb_tg_attach_31" {
  target_group_arn = aws_lb_target_group.web_lb_tg.arn
  target_id        = var.web31_ec2_id
  port             = 8080
}

resource "aws_security_group" "web_elb_sg" {
  name        = "web-elb-sg"
  description = "web-elb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "web-elb-sg"
  }
}

resource "aws_lb" "web_elb" {
  name               = "web-elb-tf"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.web_elb_sg.id]
  subnets = var.public_subnets_id
  ip_address_type            = "ipv4"
  enable_deletion_protection = false

  tags = {
    Name = "web-elb"
  }
}

resource "aws_lb_listener" "web_listener_80" {
  load_balancer_arn = aws_lb.web_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "web_listener_443" {
  load_balancer_arn = aws_lb.web_elb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = data.aws_acm_certificate.server_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_lb_tg.arn
  }
}

data "aws_acm_certificate" "server_cert" {
  domain   = "ewuung.click"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "web_ewuung_link" {
  name = "ewuung.click."
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.web_ewuung_link.zone_id
  name    = "www.${data.aws_route53_zone.web_ewuung_link.name}"
  type    = "A"
  allow_overwrite = true # 덮어쓰기
  alias {
    name                   = aws_lb.web_elb.dns_name
    zone_id                = aws_lb.web_elb.zone_id
    evaluate_target_health = true
  }
}