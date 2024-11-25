output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.web_elb.arn  # ALB ARN 값을 출력 resource "aws_lb" "web_elb"
}