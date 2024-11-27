terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
}

provider "aws" {
  profile = "terraform-user"
}

module "project_vpc" {
  source                           = "../vpc"
  env_name                         = "project"
  cidr                             = "10.1.0.0/16"
  nat_primary_network_interface_id = module.project_ec2.nat_primary_network_interface_id
}

module "project_sg" {
  source = "../sg"
  vpc_id = module.project_vpc.vpc_id
}

module "project_ec2" {
  source = "../ec2"

  public_subnets_id  = module.project_vpc.public_subnets_id
  private_subnets_id = module.project_vpc.private_subnets_id

  bastion_host_sg_id = module.project_sg.bastion_host_sg_id
  nat_sg_id          = module.project_sg.nat_sg_id
  web_sg_id          = module.project_sg.web_sg_id
  app_sg_id          = module.project_sg.app_sg_id
}

module "project_s3" {
  source            = "../S3"
  bucket_name       = "project-team2-bucket"
  kms_master_key_id = "arn:aws:kms:region:account-id:key/key-id"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = module.project_vpc.private_subnets_id
}

module "carbon_emission_rds" {
  source             = "../rds/carbon_emission"
  env_name           = module.project_vpc.env_name
  private_subnets    = module.project_vpc.private_subnets_id
  db_sg_id           = module.project_sg.db_sg_id
  db_subnet_group_id = aws_db_subnet_group.db_subnet_group.id
  db_name            = "carbon_emission_db"
  db_master_username = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_username"]
  db_master_password = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_password"]
}

module "supplier_rds" {
  source             = "../rds/supplier"
  env_name           = module.project_vpc.env_name
  private_subnets    = module.project_vpc.private_subnets_id
  db_sg_id           = module.project_sg.db_sg_id
  db_subnet_group_id = aws_db_subnet_group.db_subnet_group.id
  db_name            = "supplier_management_db"
  db_master_username = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_username"]
  db_master_password = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_password"]
}

module "app_user_rds" {
  source             = "../rds/app_user"
  env_name           = module.project_vpc.env_name
  private_subnets    = module.project_vpc.private_subnets_id
  db_sg_id           = module.project_sg.db_sg_id
  db_subnet_group_id = aws_db_subnet_group.db_subnet_group.id
  db_name            = "app_user_management_db"
  db_master_username = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_username"]
  db_master_password = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_password"]
}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "db-credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

module "project_elb" {
  source             = "../elb"
  vpc_id             = module.project_vpc.vpc_id
  public_subnets_id  = module.project_vpc.public_subnets_id
  web11_ec2_id       = module.project_ec2.web11_ec2_id
  web31_ec2_id       = module.project_ec2.web31_ec2_id
  private_subnets_id = module.project_vpc.private_subnets_id
  app12_ec2_id       = module.project_ec2.app12_ec2_id
  app32_ec2_id       = module.project_ec2.app32_ec2_id
  app13_ec2_id       = module.project_ec2.app13_ec2_id
  app33_ec2_id       = module.project_ec2.app33_ec2_id
  web14_ec2_id       = module.project_ec2.web14_ec2_id
  web34_ec2_id       = module.project_ec2.web34_ec2_id
  app15_ec2_id       = module.project_ec2.app15_ec2_id
  app35_ec2_id       = module.project_ec2.app35_ec2_id
  web_sg_id          = module.project_sg.web_sg_id
}

module "project_efs" {
  source = "../efs"

  vpc_id              = module.project_vpc.vpc_id
  public_subnets_ids  = module.project_vpc.public_subnets_id
  private_subnets_ids = module.project_vpc.private_subnets_id
  efs_sg_id           = module.project_sg.efs_sg_id
}

module "project_cloudwatch" {
  source = "../cloudwatch"
}

module "project_cloudtrail" {
  source                    = "../cloudtrail"
  cloudtrail_log_group_name = module.project_cloudwatch.cloudtrail_log_group_name
  cloudtrail_sns_topic_arn  = module.project_cloudwatch.cloudtrail_sns_topic_arn
}

# WAF 모듈 호출
module "project_waf" {
  source            = "../waf"
  alb_arn           = module.project_elb.alb_arn # ELB의 ARN을 WAF 모듈에 전달
  web_acl_name      = "waf_web_acl"      # WAF Web ACL 이름
  web_acl_scope     = "REGIONAL"
  allowed_ip_ranges = ["203.0.113.0/24", "198.51.100.0/24"] # 허용된 IP 목록
  blocked_ip_ranges = ["192.0.2.0/24"]                      # 차단된 IP 목록
  rate_limit        = 1000                                  # 속도 제한 (1,000 요청/5초)
}
