output "elb_domain_name" {
  value = aws_lb.web_elb.dns_name
}

