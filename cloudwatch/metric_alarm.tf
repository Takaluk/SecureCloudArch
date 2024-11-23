resource "aws_cloudwatch_metric_alarm" "ec2_state_change_alarm" {
  alarm_name          = "EC2StateChangeAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Events"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.ec2_instance_state_change.name
  }

  alarm_actions = [module.ec2_notifications.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "efs_lifecycle_change_alarm" {
  alarm_name          = "EFSLifecycleChangeAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Events"
  namespace           = "AWS/EFS"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.efs_lifecycle_events.name
  }

  alarm_actions = [module.efs_notifications.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "elb_state_change_alarm" {
  alarm_name          = "ELBStateChangeAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Events"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.elb_state_change.name
  }

  alarm_actions = [module.elb_notifications.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_event_alarm" {
  alarm_name          = "RDSEventAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Events"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.rds_events.name
  }

  alarm_actions = [module.rds_notifications.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "s3_policy_change_alarm" {
  alarm_name          = "S3PolicyChangeAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Events"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.s3_policy_change.name
  }

  alarm_actions = [module.s3_notifications.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "security_group_change_alarm" {
  alarm_name          = "SecurityGroupChangeAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Events"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.security_group_change.name
  }

  alarm_actions = [module.security_group_notifications.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "vpc_change_alarm" {
  alarm_name          = "VPCChangeAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Events"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.vpc_change.name
  }

  alarm_actions = [module.vpc_notifications.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "waf_shield_alarm" {
  alarm_name          = "WAFShieldAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Events"
  namespace           = "AWS/WAF"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.waf_shield_events.name
  }

  alarm_actions = [module.waf_shield_notifications.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_alarm" {
  alarm_name          = "CloudTrailAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "SuspiciousEventCount"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1
  alarm_description   = "Triggered by specific CloudTrail events"

  alarm_actions = [module.cloudtrail_notifications.topic_arn]
}


resource "aws_sns_topic_subscription" "ec2_event_email_subscription" {
  topic_arn = module.ec2_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com"
}

resource "aws_sns_topic_subscription" "efs_event_email_subscription" {
  topic_arn = module.efs_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com"
}

resource "aws_sns_topic_subscription" "elb_event_email_subscription" {
  topic_arn = module.elb_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com"
}

resource "aws_sns_topic_subscription" "rds_event_email_subscription" {
  topic_arn = module.rds_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com"
}

resource "aws_sns_topic_subscription" "s3_event_email_subscription" {
  topic_arn = module.s3_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com"
}

resource "aws_sns_topic_subscription" "security_group_event_email_subscription" {
  topic_arn = module.security_group_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com"
}

resource "aws_sns_topic_subscription" "vpc_event_email_subscription" {
  topic_arn = module.vpc_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com"
}

resource "aws_sns_topic_subscription" "waf_shield_event_email_subscription" {
  topic_arn = module.waf_shield_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com"
}

resource "aws_sns_topic_subscription" "cloudtrail_event_email_subscription" {
  topic_arn = module.cloudtrail_notifications.topic_arn
  protocol  = "email"
  endpoint  = "julysnowflake@naver.com" 
}