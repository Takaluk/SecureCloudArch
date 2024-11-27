resource "aws_iam_role" "cloudtrail_role" {
  name = "CloudTrailRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudtrail_policy" {
  name        = "CloudTrailPolicy"
  description = "Policy for CloudTrail to write to S3 and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = "${module.project2_cloudtrail_s3_bucket.bucket_arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/aws/cloudtrail/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "cloudtrail_policy_attachment" {
  name       = "cloudtrail_policy_attachment"
  roles      = [aws_iam_role.cloudtrail_role.name]
  policy_arn = aws_iam_policy.cloudtrail_policy.arn
}

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name = "cloudtrail-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_policy" {
  name   = "cloudtrail-cloudwatch-policy"
  role   = aws_iam_role.cloudtrail_cloudwatch_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "logs:PutLogEvents"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudtrail_log_group_name}:*"
        Effect   = "Allow"
      },
      {
        Action   = "logs:CreateLogStream"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudtrail_log_group_name}:*"
        Effect   = "Allow"
      },
      {
        Action   = "logs:DescribeLogStreams"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudtrail_log_group_name}:*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "cloudtrail_s3_policy" {
  bucket = module.project2_cloudtrail_s3_bucket.bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudTrailWrite",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "${module.project2_cloudtrail_s3_bucket.bucket_arn}/*"
      },
      {
        Sid       = "AllowCloudTrailGetBucketAcl",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = [
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource  = "${module.project2_cloudtrail_s3_bucket.bucket_arn}"
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "cloudtrail_cors" {
  bucket = module.project2_cloudtrail_s3_bucket.bucket_id

  cors_rule {
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }
}
