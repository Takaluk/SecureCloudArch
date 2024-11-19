module "ec2_notifications" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "ec2_notifications"
}

module "efs_notifications" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "efs_notifications"
}

module "elb_notifications" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "elb_notifications"
}

module "rds_notifications" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "rds_notifications"
}

module "s3_notifications" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "s3_notifications"
}

module "security_group_notifications" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "security_group_notifications"
}

module "vpc_notifications" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "vpc_notifications"
}

module "waf_shield_notifications" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "waf_shield_notifications"
}
