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


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2c", "ap-northeast-2a"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Name = "module-vpc"
  }
}

module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion-sg"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "all-icmp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  use_name_prefix = false # 이름이 자동으로 변경되지 않도록
}

module "nat_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "nat-sg"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  use_name_prefix = false # 이름이 자동으로 변경되지 않도록
}

module "web_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-sg"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "all-icmp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  use_name_prefix = false # 이름이 자동으로 변경되지 않도록
}

module "bastion_host_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "bastion-host-instance"
  ami                         = "ami-0353b1ac0dd577556"
  instance_type               = "t2.micro"
  key_name                    = "public-ec2-key"
  monitoring                  = true
  vpc_security_group_ids      = [module.bastion_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  tags = {
    Name = "bastion-host-instance"
  }
}

module "nat_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "nat-instance"
  ami                         = "ami-01ad0c7a4930f0e43"
  instance_type               = "t2.micro"
  key_name                    = "public-ec2-key"
  monitoring                  = true
  vpc_security_group_ids      = [module.nat_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[1]
  associate_public_ip_address = true
  source_dest_check           = false
  tags = {
    Name = "nat-instance"
  }
}

module "web_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "web-instance"
  ami                         = "ami-0353b1ac0dd577556"
  instance_type               = "t2.micro"
  key_name                    = "Web-key"
  monitoring                  = true
  vpc_security_group_ids      = [module.web_sg.security_group_id]
  count                       = 2
  subnet_id                   = module.vpc.private_subnets[count.index] # 위 vpc 모듈에서 지정함
  associate_public_ip_address = true
  tags = {
    Name = "web-instance"
  }
}

resource "aws_route" "private_route" {
  count                  = 2
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat_instance.primary_network_interface_id
}