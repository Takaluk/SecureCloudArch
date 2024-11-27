

# WAF Web ACL 생성
resource "aws_wafv2_web_acl" "waf_web_acl" {
  name  = var.web_acl_name
  scope = var.web_acl_scope

  default_action {
    allow {} # 기본 허용
  }

  visibility_config {
    cloudwatch_metrics_enabled = true # CloudWatch 연동
    metric_name                = "${var.web_acl_name}-metrics"  # 메트릭 이름
    sampled_requests_enabled   = true  # 샘플링 활성화
  }

  # 허용 규칙 (IP 허용)
  rule {
    name     = "AllowSpecificIPs"
    priority = 1
    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ips.arn # 허용된 IP 세트 ARN 참조
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allow-specific-ips"
      sampled_requests_enabled   = true
    }
  }

  # 차단 규칙 (IP 차단)
  rule {
    name     = "BlockSpecificIPs"
    priority = 2
    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn # 차단된 IP 세트 ARN 참조
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-specific-ips"
      sampled_requests_enabled   = true
    }
  }

 # 속도 제한 규칙
  rule {
    name     = "RateLimit"
    priority = 3
    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP" # 기준 키
        limit              = var.rate_limit # 속도 제한 값
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = true
    }
  }
}

# 허용 IP 목록
resource "aws_wafv2_ip_set" "allowed_ips" {
  name          = "${var.web_acl_name}-allowed-ips"
  scope         = var.web_acl_scope
  ip_address_version = "IPV4"

  addresses = var.allowed_ip_ranges
}

# 차단 IP 목록
resource "aws_wafv2_ip_set" "blocked_ips" {
  name          = "${var.web_acl_name}-blocked-ips"
  scope         = var.web_acl_scope
  ip_address_version = "IPV4"

  addresses = var.blocked_ip_ranges
}

# WAF를 ALB에 연결
resource "aws_wafv2_web_acl_association" "association" {
  resource_arn = var.alb_arn # ALB ARN 참조 resource "aws_lb" "web_elb" 
  web_acl_arn  = aws_wafv2_web_acl.waf_web_acl.arn # WAF ARN 참조
}