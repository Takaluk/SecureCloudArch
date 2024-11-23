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

module "yeji_vpc" {
  source                           = "../vpc"
  env_name                         = "yeji"
  cidr                             = "10.2.0.0/16"
  nat_primary_network_interface_id = module.yeji_ec2.nat_primary_network_interface_id
}

module "yeji_sg" {
  source = "../sg"
  vpc_id = module.yeji_vpc.vpc_id
}

module "yeji_ec2" {
  source = "../ec2"

  public_subnets_id  = module.yeji_vpc.public_subnets_id
  private_subnets_id = module.yeji_vpc.private_subnets_id

  bastion_host_sg_id = module.yeji_sg.bastion_host_sg_id
  nat_sg_id          = module.yeji_sg.nat_sg_id
  web_sg_id          = module.yeji_sg.web_sg_id
  app_sg_id          = module.yeji_sg.app_sg_id
}

module "yeji_elb" {
  source             = "../elb"
  vpc_id             = module.yeji_vpc.vpc_id
  public_subnets_id  = module.yeji_vpc.public_subnets_id
  web11_ec2_id       = module.yeji_ec2.web11_ec2_id
  web31_ec2_id       = module.yeji_ec2.web31_ec2_id
  private_subnets_id = module.yeji_vpc.private_subnets_id
  app12_ec2_id       = module.yeji_ec2.app12_ec2_id
  app32_ec2_id       = module.yeji_ec2.app32_ec2_id

  web_sg_id = module.yeji_sg.web_sg_id
}

module "yeji_efs" {
  source = "../efs"

  vpc_id              = module.yeji_vpc.vpc_id
  public_subnets_ids  = module.yeji_vpc.public_subnets_id
  private_subnets_ids = module.yeji_vpc.private_subnets_id
  efs_sg_id           = module.yeji_sg.efs_sg_id
}

module "yeji_cloudwatch" {
  source = "../cloudwatch"
}

module "yeji_cloudtrail" {
  source                    = "../cloudtrail"
  cloudtrail_log_group_name = module.yeji_cloudwatch.cloudtrail_log_group_name
  cloudtrail_sns_topic_arn  = module.yeji_cloudwatch.cloudtrail_sns_topic_arn
}
