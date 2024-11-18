module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion-sg"
  description = "bastion-sg"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
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

module "nat_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "nat-sg"
  description = "nat-sg"
  vpc_id      = var.vpc_id

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
  description = "web-sg"
  vpc_id      = var.vpc_id

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

module "app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "app-sg"
  description = "app-sg"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
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

module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "db-sg"
  description = "db-sg"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      rule    = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  use_name_prefix = false  # 이름이 자동으로 변경되지 않도록
}