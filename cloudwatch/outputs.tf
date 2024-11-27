output "cloudtrail_log_group_name" {
  value = aws_cloudwatch_log_group.cloudtrail_log_group.name
}

output "cloudtrail_sns_topic_arn" {
  value = module.cloudtrail_notifications.topic_arn
}