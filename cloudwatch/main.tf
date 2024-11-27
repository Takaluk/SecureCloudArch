resource "aws_kms_key" "cloudwatch_kms" {
  description             = "KMS key for CloudWatch logs encryption"
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-2",
    Statement: [
      {
        Sid       = "Enable IAM User Permissions",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow CloudWatch Logs to use the KMS key",
        Effect    = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource  = "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "/aws/cloudwatch/project2"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.cloudwatch_kms.arn 
}

resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name = "/aws/cloudtrail/project2"
  retention_in_days = 30
}

module "cloudwatch_log_metric_filter" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "~> 3.0"

  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name

  name    = "CloudWatch_Error_Metric_Filter"
  pattern = "ERROR"

  metric_transformation_namespace = "Cloudwatch_Metrics"
  metric_transformation_name      = "Cloudwatch_ErrorCount"
}

resource "aws_cloudwatch_log_metric_filter" "cloudtrail_event_filter" {
  name           = "CloudTrail_Event_Filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern = "{ ($.eventName = \"DeleteBucket\" || $.eventName = \"StopInstances\") }"

  metric_transformation {
    name      = "cloudtrail_SuspiciousEventCount"
    namespace = "CloudTrail_Metrics"
    value     = "1"
  }
}

module "log_stream" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-stream"
  version = "~> 3.0"

  name           = "stream1"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
}

resource "aws_iam_role" "cloudwatch_role" {
  name = "cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name   = "cloudwatch-policy"
  role   = aws_iam_role.cloudwatch_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "cloudwatch:PutMetricData",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}