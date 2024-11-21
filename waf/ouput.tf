# WAF Web ACL ARN 출력
output "web_acl_arn" {
  value       = aws_wafv2_web_acl.waf_web_acl.arn # WAF의 ARN 출력
  description = "The ARN of the WAF Web ACL" # 출력 설명
}