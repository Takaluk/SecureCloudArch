provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "project-team2-bucket" {
  bucket = var.bucket_name
}

# S3 버킷에서 버전 관리를 제어하기 위한 리소스 제공
resource "aws_s3_bucket_versioning" "s3bucket_versioning" {
  bucket = aws_s3_bucket.project-team2-bucket.id

  # 버킷이 파일을 업데이트할 때마다 새 버전 생성
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 버킷에 기록된 모든 데이터에 서버 측 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "s3bucket_encryption" {
  bucket = aws_s3_bucket.project-team2-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_master_key_id
    }
  }
}

# S3 버킷 퍼블릭 액세스 차단 구성 관리
resource "aws_s3_bucket_public_access_block" "s3bucket_public-access" {
  bucket = aws_s3_bucket.project-team2-bucket.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 버킷 정책 추가
resource "aws_s3_bucket_policy" "s3bucket_policy" {
    bucket = aws_s3_bucket.project-team2-bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Id = "PutObjectPolicy"
        Statement = [
            {
                Sid = "DenyIncorrectEncryptionHeader"
                Effect = "Deny"
                Principal = "*"
                Action = "s3:PutObject"
                Resource = "arn:aws:s3:::${aws_s3_bucket.project-team2-bucket.bucket}/*"
                Condition = {
                    StringNotEquals = {
                        "s3:x-amz-server-side-encryption" = "AES256"
                    }
                }
            },
            {
                Sid = "DenyUnencryptedObjectUploads"
                Effect = "Deny"
                Principal = "*"
                Action = "s3:PutObject"
                Resource = "arn:aws:s3:::${aws_s3_bucket.project-team2-bucket.bucket}/*"
                Condition = {
                    Null = {
                        "s3:x-amz-server-side-encryption" = "true"
                    }
                }
            }
        ]
    })
}

