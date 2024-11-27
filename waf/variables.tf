variable "web_acl_name" {
  description = "Name of the WAF Web ACL"
  type        = string
}

variable "web_acl_scope" {
  description = "WAF Scope (REGIONAL)"
  type        = string
}

variable "alb_arn" {  #elb/output.tf에 출력값 정의
  description = "ARN of the ELB to associate with the WAF"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "허용된 IP 범위 목록"
  type        = list(string)
}

variable "blocked_ip_ranges" {
  description = "차단된 IP 범위 목록"
  type        = list(string)
}

variable "rate_limit" {
  description = "Rate limit 요청 수"
  type        = number
}