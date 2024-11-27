resource "aws_kms_key" "cloudtrail_kms" {
  description             = "KMS key for CloudTrail logs encryption"
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-1",
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
        Sid       = "Allow CloudTrail to use the KMS key",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource  = "*"
      }
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "cloudtrail" {
  source = "cloudposse/cloudtrail/aws"
  version     = "0.24.0"
  namespace                     = "project2_cloudtrail_s3"
  stage                         = "dev"
  name                          = "project2_cloudtrail"
  
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true

  s3_bucket_name                = module.project2_cloudtrail_s3_bucket.bucket_id
  kms_key_arn = aws_kms_key.cloudtrail_kms.arn
  
  cloud_watch_logs_role_arn = aws_iam_role.cloudtrail_cloudwatch_role.arn
  cloud_watch_logs_group_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudtrail_log_group_name}:*"
  sns_topic_name = var.cloudtrail_sns_topic_arn
}

module "project2_cloudtrail_s3_bucket" {
  source = "cloudposse/cloudtrail-s3-bucket/aws"
  version     = "0.25.0"
  namespace = "project2_cloudtrail_s3"
  stage     = "dev"
  name      = "project2_cloudtrail_logs"
}

