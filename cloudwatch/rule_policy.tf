# 다른 AWS 서비스와의 통합을 위한 policy 설정

resource "aws_sns_topic_policy" "ec2_sns_policy" {
  arn = module.ec2_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = module.ec2_notifications.topic_arn
    }]
  })
}

resource "aws_sns_topic_policy" "efs_sns_policy" {
  arn = module.efs_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = module.efs_notifications.topic_arn
    }]
  })
}

resource "aws_sns_topic_policy" "elb_sns_policy" {
  arn = module.elb_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = module.elb_notifications.topic_arn
    }]
  })
}

resource "aws_sns_topic_policy" "rds_sns_policy" {
  arn = module.rds_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = module.rds_notifications.topic_arn
    }]
  })
}

resource "aws_sns_topic_policy" "s3_sns_policy" {
  arn = module.s3_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = module.s3_notifications.topic_arn
    }]
  })
}

resource "aws_sns_topic_policy" "security_group_sns_policy" {
  arn = module.security_group_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = module.security_group_notifications.topic_arn
    }]
  })
}

resource "aws_sns_topic_policy" "vpc_sns_policy" {
  arn = module.vpc_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = module.vpc_notifications.topic_arn
    }]
  })
}

resource "aws_sns_topic_policy" "waf_shield_sns_policy" {
  arn = module.waf_shield_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = module.waf_shield_notifications.topic_arn
    }]
  })
}

resource "aws_sns_topic_policy" "cloudtrail_sns_policy" {
  arn = module.cloudtrail_notifications.topic_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "SNS:Publish"
        Resource  = module.cloudtrail_notifications.topic_arn
      }
    ]
  })
}
