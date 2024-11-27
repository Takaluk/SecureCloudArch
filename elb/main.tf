# internet facing lb
resource "aws_lb_target_group" "usermanage_web_lb_tg" {
  name     = "usermanage-web-lb-tg"
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
resource "aws_lb_target_group" "partner_web_lb_tg" {
  name     = "partner-web-lb-tg"
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
resource "aws_lb_target_group_attachment" "usermanage_web_lb_tg_attach_11" {
  target_group_arn = aws_lb_target_group.usermanage_web_lb_tg.arn
  target_id        = var.web11_ec2_id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "usermanage_web_lb_tg_attach_31" {
  target_group_arn = aws_lb_target_group.usermanage_web_lb_tg.arn
  target_id        = var.web31_ec2_id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "partner_web_lb_tg_attach_14" {
  target_group_arn = aws_lb_target_group.partner_web_lb_tg.arn
  target_id        = var.web14_ec2_id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "partner_web_lb_tg_attach_34" {
  target_group_arn = aws_lb_target_group.partner_web_lb_tg.arn
  target_id        = var.web34_ec2_id
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

resource "aws_lb" "usermanage_web_lb" {
  name               = "usermanage-web-elb-tf"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.web_elb_sg.id]
  subnets = var.public_subnets_id
  ip_address_type            = "ipv4"
  enable_deletion_protection = false

  tags = {
    Name = "usermanage-web-elb"
  }
}
resource "aws_lb" "partner_web_lb" {
  name               = "partner-web-elb-tf"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.web_elb_sg.id]
  subnets = var.public_subnets_id
  ip_address_type            = "ipv4"
  enable_deletion_protection = false

  tags = {
    Name = "partner-web-elb"
  }
}

resource "aws_lb_listener" "usermanage_web_listener_80" {
  load_balancer_arn = aws_lb.usermanage_web_lb.arn
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
resource "aws_lb_listener" "partner_web_listener_80" {
  load_balancer_arn = aws_lb.partner_web_lb.arn
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


resource "aws_lb_listener" "usermanage_listener_443" {
  load_balancer_arn = aws_lb.usermanage_web_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = data.aws_acm_certificate.server_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.usermanage_web_lb_tg.arn
  }
}
resource "aws_lb_listener" "partner_listener_443" {
  load_balancer_arn = aws_lb.partner_web_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = data.aws_acm_certificate.server_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.partner_web_lb_tg.arn
  }
}

data "aws_acm_certificate" "server_cert" {
  domain   = "ewuung.click"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "web_ewuung_link" {
  name = "ewuung.click."
}

resource "aws_route53_record" "www_usermanage" {
  zone_id = data.aws_route53_zone.web_ewuung_link.zone_id
  name    = "www.usermanage.${data.aws_route53_zone.web_ewuung_link.name}"
  type    = "A"
  allow_overwrite = true # 덮어쓰기
  alias {
    name                   = aws_lb.usermanage_web_lb.dns_name
    zone_id                = aws_lb.usermanage_web_lb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "www_partner" {
  zone_id = data.aws_route53_zone.web_ewuung_link.zone_id
  name    = "www.partner.${data.aws_route53_zone.web_ewuung_link.name}"
  type    = "A"
  allow_overwrite = true # 덮어쓰기
  alias {
    name                   = aws_lb.partner_web_lb.dns_name
    zone_id                = aws_lb.partner_web_lb.zone_id
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
    path    = "/api/auth/healthcheck"
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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
    "Name" = "auth-service-elb-sg"
  }
}

resource "aws_lb" "auth-service_elb" {
  name               = "auth-service-elb-tf"
  load_balancer_type = "application"
  internal           = true
  security_groups    = [aws_security_group.auth-service_elb_sg.id]
  subnets            = [var.private_subnets_id[0], var.private_subnets_id[1]]
  ip_address_type    = "ipv4"

  tags = {
    Name = "auth-service-elb"
  }
}

resource "aws_lb_listener" "auth-service_listener_80" {
  load_balancer_arn = aws_lb.auth-service_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth-service_lb_tg.arn
  }
}

resource "aws_route53_record" "auth-service.ewuung.click" {
  zone_id = data.aws_route53_zone.web_ewuung_link.zone_id
  name    = "auth-service.${data.aws_route53_zone.web_ewuung_link.name}"
  type    = "A"
  allow_overwrite = true # 덮어쓰기
  alias {
    name                   = aws_lb.auth-service_elb.dns_name
    zone_id                = aws_lb.auth-service_elb.zone_id
    evaluate_target_health = true
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

    path    = "/api/roles/healthcheck"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "role-service_lb_tg_attach_12" {
  target_group_arn = aws_lb_target_group.role-service_lb_tg.arn
  target_id        = var.app12_ec2_id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "role-service_lb_tg_attach_32" {
  target_group_arn = aws_lb_target_group.role-service_lb_tg.arn
  target_id        = var.app32_ec2_id
  port             = 8080
}

resource "aws_security_group" "role-service_elb_sg" {
  name        = "role-service-elb-sg"
  description = "role-service-elb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    "Name" = "role-service-elb-sg"
  }
}

resource "aws_lb" "role-service_elb" {
  name               = "role-service-elb-tf"

  load_balancer_type = "application"

  internal           = true
  security_groups    = [aws_security_group.role-service_elb_sg.id]
  subnets            = [var.private_subnets_id[0], var.private_subnets_id[1]]
  ip_address_type    = "ipv4"

  tags = {
    Name = "role-service-elb"
  }
}

resource "aws_lb_listener" "role-service_listener_80" {
  load_balancer_arn = aws_lb.role-service_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.role-service_lb_tg.arn 
  }
}

resource "aws_route53_record" "role-service.ewuung.click" {
  zone_id = data.aws_route53_zone.web_ewuung_link.zone_id
  name    = "role-service.${data.aws_route53_zone.web_ewuung_link.name}"
  type    = "A"
  allow_overwrite = true # 덮어쓰기
  alias {
    name                   = aws_lb.role-service_elb.dns_name
    zone_id                = aws_lb.role-service_elb.zone_id
    evaluate_target_health = true
  }
}

# internal carbon-service facing lb
resource "aws_lb_target_group" "carbon-service_lb_tg" {
  name     = "carbon-service-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
  }

  health_check {

    path    = "/api/partners/healthcheck"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "carbon-service_lb_tg_attach_13" {
  target_group_arn = aws_lb_target_group.carbon-service_lb_tg.arn
  target_id        = var.app15_ec2_id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "carbon-service_lb_tg_attach_33" {
  target_group_arn = aws_lb_target_group.carbon-service_lb_tg.arn
  target_id        = var.app35_ec2_id
  port             = 8080
}

resource "aws_security_group" "carbon-service_elb_sg" {
  name        = "carbon-service-elb-sg"
  description = "carbon-service-elb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    "Name" = "carbon-service-elb-sg"
  }
}

resource "aws_lb" "carbon-service_elb" {
  name               = "carbon-service-elb-tf"

  load_balancer_type = "application"

  internal           = true
  security_groups    = [aws_security_group.carbon-service_elb_sg.id]
  subnets            = [var.private_subnets_id[0], var.private_subnets_id[1]]
  ip_address_type    = "ipv4"

  tags = {
    Name = "carbon-service-elb"
  }
}

resource "aws_lb_listener" "carbon-service_listener_80" {
  load_balancer_arn = aws_lb.carbon-service_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.carbon-service_lb_tg.arn 
  }
}

resource "aws_route53_record" "carbon-service.ewuung.click" {
  zone_id = data.aws_route53_zone.web_ewuung_link.zone_id
  name    = "carbon-service.${data.aws_route53_zone.web_ewuung_link.name}"
  type    = "A"
  allow_overwrite = true # 덮어쓰기
  alias {
    name                   = aws_lb.carbon-service_elb.dns_name
    zone_id                = aws_lb.carbon-service_elb.zone_id
    evaluate_target_health = true
  }
}