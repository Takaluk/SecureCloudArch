# event_rule - EC2 state change
resource "aws_cloudwatch_event_rule" "ec2_instance_state_change" {
  name        = "EC2InstanceStateChangeRule"
  description = "Monitor EC2 instance state changes"
  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "ec2_target" {
  rule = aws_cloudwatch_event_rule.ec2_instance_state_change.name
  arn  = module.ec2_notifications.topic_arn
}

# event_rule - EFS lifecycle change
resource "aws_cloudwatch_event_rule" "efs_lifecycle_events" {
  name        = "EFSLifecycleRule"
  description = "Monitor EFS lifecycle changes"
  event_pattern = <<PATTERN
{
  "source": ["aws.efs"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["CreateFileSystem", "DeleteFileSystem"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "efs_target" {
  rule = aws_cloudwatch_event_rule.efs_lifecycle_events.name
  arn  = module.efs_notifications.topic_arn
}

# event_rule - ELB state change
resource "aws_cloudwatch_event_rule" "elb_state_change" {
  name        = "ELBStateChangeRule"
  description = "Monitor ELB instance state changes"
  event_pattern = <<PATTERN
{
  "source": ["aws.elasticloadbalancing"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["RegisterTargets", "DeregisterTargets"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "elb_target" {
  rule = aws_cloudwatch_event_rule.elb_state_change.name
  arn  = module.elb_notifications.topic_arn
}

# event_rule - RDS events check
resource "aws_cloudwatch_event_rule" "rds_events" {
  name        = "RDSEventRule"
  description = "Monitor RDS events"
  event_pattern = <<PATTERN
{
  "source": ["aws.rds"],
  "detail-type": ["RDS DB Instance Event"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "rds_target" {
  rule = aws_cloudwatch_event_rule.rds_events.name
  arn  = module.rds_notifications.topic_arn
}

# event_rule - S3 bucket policy change
resource "aws_cloudwatch_event_rule" "s3_policy_change" {
  name        = "S3PolicyChangeRule"
  description = "Monitor S3 bucket policy changes"
  event_pattern = <<PATTERN
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["PutBucketPolicy", "DeleteBucketPolicy"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "s3_target" {
  rule = aws_cloudwatch_event_rule.s3_policy_change.name
  arn  = module.s3_notifications.topic_arn
}

# event_rule - Security Group rule change
resource "aws_cloudwatch_event_rule" "security_group_change" {
  name        = "SecurityGroupChangeRule"
  description = "Monitor security group changes"
  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["AuthorizeSecurityGroupIngress", "RevokeSecurityGroupIngress"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sg_target" {
  rule = aws_cloudwatch_event_rule.security_group_change.name
  arn  = module.security_group_notifications.topic_arn
}

# event_rule - VPC subnet add and delete
resource "aws_cloudwatch_event_rule" "vpc_change" {
  name        = "VPCChangeRule"
  description = "Monitor VPC configuration changes"
  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["CreateSubnet", "DeleteSubnet"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "vpc_target" {
  rule = aws_cloudwatch_event_rule.vpc_change.name
  arn  = module.vpc_notifications.topic_arn
}

# event_rule - WAF & Shield security events
resource "aws_cloudwatch_event_rule" "waf_shield_events" {
  name        = "WAFShieldEventRule"
  description = "Monitor WAF and Shield events"
  event_pattern = <<PATTERN
{
  "source": ["aws.shield", "aws.waf"],
  "detail-type": ["AWS API Call via CloudTrail"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "waf_shield_target" {
  rule = aws_cloudwatch_event_rule.waf_shield_events.name
  arn  = module.waf_shield_notifications.topic_arn
}

# event_rule - cloudtrail_API_call_events
resource "aws_cloudwatch_event_rule" "cloudtrail_events" {
  name        = "CloudTrailEventsRule"
  description = "Monitor CloudTrail suspicious events"
  event_pattern = <<PATTERN
{
  "source": ["aws.cloudtrail"],
  "detail-type": ["AWS API Call via CloudTrail"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "cloudtrail_target" {
  rule = aws_cloudwatch_event_rule.cloudtrail_events.name
  arn  = module.cloudtrail_notifications.topic_arn
}