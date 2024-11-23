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

module "ewunng_vpc" {
  source                           = "../vpc"
  env_name                         = "ewunng"
  cidr                             = "10.1.0.0/16"
  nat_primary_network_interface_id = module.ewunng_ec2.nat_primary_network_interface_id
}

module "ewunng_sg" {
  source = "../sg"
  vpc_id = module.ewunng_vpc.vpc_id
}

module "ewunng_ec2" {
  source = "../ec2"

  public_subnets_id  = module.ewunng_vpc.public_subnets_id
  private_subnets_id = module.ewunng_vpc.private_subnets_id

  bastion_host_sg_id = module.ewunng_sg.bastion_host_sg_id
  nat_sg_id          = module.ewunng_sg.nat_sg_id
  web_sg_id          = module.ewunng_sg.web_sg_id
  app_sg_id          = module.ewunng_sg.app_sg_id
}

module "ewunng_s3" {
  source            = "../S3"
  bucket_name       = "project-team2-bucket"
  kms_master_key_id = "arn:aws:kms:region:account-id:key/key-id"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = module.ewunng_vpc.private_subnets_id
}

module "carbon_emission_rds" {
  source             = "../rds/carbon_emission"
  env_name           = module.ewunng_vpc.env_name
  private_subnets    = module.ewunng_vpc.private_subnets_id
  db_sg_id           = module.ewunng_sg.db_sg_id
  db_subnet_group_id = aws_db_subnet_group.db_subnet_group.id
  db_name            = "carbon_emission_db"
  db_master_username = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_username"]
  db_master_password = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_password"]
}

module "supplier_rds" {
  source             = "../rds/supplier"
  env_name           = module.ewunng_vpc.env_name
  private_subnets    = module.ewunng_vpc.private_subnets_id
  db_sg_id           = module.ewunng_sg.db_sg_id
  db_subnet_group_id = aws_db_subnet_group.db_subnet_group.id
  db_name            = "supplier_management_db"
  db_master_username = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_username"]
  db_master_password = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["db_master_password"]
}

module "app_user_rds" {
  source             = "../rds/app_user"
  env_name           = module.ewunng_vpc.env_name
  private_subnets    = module.ewunng_vpc.private_subnets_id
  db_sg_id           = module.ewunng_sg.db_sg_id
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

module "ewunng_elb" {
  source = "../elb"
  vpc_id = module.ewunng_vpc.vpc_id
  public_subnets_id = module.ewunng_vpc.public_subnets_id
  web11_ec2_id = module.ewunng_ec2.web11_ec2_id
  web31_ec2_id = module.ewunng_ec2.web31_ec2_id
  private_subnets_id = module.ewunng_vpc.private_subnets_id
  app12_ec2_id = module.ewunng_ec2.app12_ec2_id
  app32_ec2_id = module.ewunng_ec2.app32_ec2_id
  app13_ec2_id = module.ewunng_ec2.app13_ec2_id
  app33_ec2_id = module.ewunng_ec2.app33_ec2_id
  web_sg_id = module.ewunng_sg.web_sg_id
}