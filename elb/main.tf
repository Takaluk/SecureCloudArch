# internet facing lb
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
    path    = "/healthcheck"
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


# internal auth-service facing lb
resource "aws_lb_target_group" "auth-service_lb_tg" {
  name     = "auth-service-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
  }

  health_check {
    path    = "/healthcheck"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "auth-service_lb_tg_attach_12" {
  target_group_arn = aws_lb_target_group.auth-service_lb_tg.arn
  target_id        = var.app12_ec2_id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "auth-service_lb_tg_attach_32" {
  target_group_arn = aws_lb_target_group.auth-service_lb_tg.arn
  target_id        = var.app32_ec2_id
  port             = 8080
}

resource "aws_security_group" "auth-service_elb_sg" {
  name        = "auth-service-elb-sg"
  description = "auth-service-elb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [var.web_sg_id] # webserver의 접근만 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "auth-service-elb-sg"
  }
}

resource "aws_lb" "auth-service_elb" {
  name               = "auth-service-elb-tf"
  load_balancer_type = "auth-servicelication"
  internal           = true
  security_groups    = [aws_security_group.auth-service_elb_sg.id]
  subnets            = [var.private_subnets_id[0], var.private_subnets_id[1]]
  ip_address_type    = "ipv4"

  tags = {
    Name = "auth-service-elb"
  }
}

# 내부망 HTTP (8080) 리스너 설정
resource "aws_lb_listener" "auth-service_listener_8080" {
  load_balancer_arn = aws_lb.auth-service_elb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"  # 영구 리디렉션
    }
  }
}

# 내부망 HTTPS (443) 리스너 설정
resource "aws_lb_listener" "auth-service_listener_443" {
  load_balancer_arn = aws_lb.auth-service_elb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # TLS 1.2 및 1.3 사용
  certificate_arn   = data.aws_acm_certificate.server_cert.arn  # ACM 인증서 사용

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth-service_lb_tg.arn  # 트래픽을 내부 타겟 그룹으로 포워딩
  }
}

# internal role-service facing lb
resource "aws_lb_target_group" "role-service_lb_tg" {
  name     = "role-service-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
  }

  health_check {
    path    = "/healthcheck"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "role-service_lb_tg_attach_12" {
  target_group_arn = aws_lb_target_group.role-service_lb_tg.arn
  target_id        = var.app13_ec2_id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "role-service_lb_tg_attach_32" {
  target_group_arn = aws_lb_target_group.role-service_lb_tg.arn
  target_id        = var.app33_ec2_id
  port             = 8080
}

resource "aws_security_group" "role-service_elb_sg" {
  name        = "role-service-elb-sg"
  description = "role-service-elb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [var.web_sg_id] # webserver의 접근만 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "role-service-elb-sg"
  }
}

resource "aws_lb" "role-service_elb" {
  name               = "role-service-elb-tf"
  load_balancer_type = "role-servicelication"
  internal           = true
  security_groups    = [aws_security_group.role-service_elb_sg.id]
  subnets            = [var.private_subnets_id[0], var.private_subnets_id[1]]
  ip_address_type    = "ipv4"

  tags = {
    Name = "role-service-elb"
  }
}

# 내부망 HTTP (8080) 리스너 설정
resource "aws_lb_listener" "role-service_listener_8080" {
  load_balancer_arn = aws_lb.role-service_elb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"  # 영구 리디렉션
    }
  }
}

# 내부망 HTTPS (443) 리스너 설정
resource "aws_lb_listener" "role-service_listener_443" {
  load_balancer_arn = aws_lb.role-service_elb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # TLS 1.2 및 1.3 사용
  certificate_arn   = data.aws_acm_certificate.server_cert.arn  # ACM 인증서 사용

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.role-service_lb_tg.arn  # 트래픽을 내부 타겟 그룹으로 포워딩
  }
}