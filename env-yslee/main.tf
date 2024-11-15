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

module "yslee_vpc" {
  source = "../vpc"
  env_name = "yslee"
  cidr = "10.0.0.0/16"
  nat_primary_network_interface_id = module.yslee_ec2.nat_primary_network_interface_id
}

module "yslee_sg" {
  source = "../sg"
  vpc_id = module.yslee_vpc.vpc_id
}

module "yslee_ec2" {
  source = "../ec2"

  public_subnets_id = module.yslee_vpc.public_subnets_id
  private_subnets_id = module.yslee_vpc.private_subnets_id

  bastion_host_sg_id = module.yslee_sg.bastion_host_sg_id
  nat_sg_id = module.yslee_sg.nat_sg_id
  web_sg_id = module.yslee_sg.web_sg_id
  app_sg_id = module.yslee_sg.app_sg_id
}