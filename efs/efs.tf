module "efs_kms" {
  source = "terraform-aws-modules/kms/aws"

  key_usage   = "ENCRYPT_DECRYPT"

  # Policy
  key_administrators = [
    "arn:aws:iam::761018879361:user/ewunng",
    "arn:aws:iam::761018879361:user/takaluk",
    "arn:aws:iam::761018879361:user/yeji",
    "arn:aws:iam::761018879361:user/yunju"
    ] # 키 관리자 권한
  key_service_users  = [
    "arn:aws:iam::761018879361:user/ewunng",
    "arn:aws:iam::761018879361:user/takaluk",
    "arn:aws:iam::761018879361:user/yeji",
    "arn:aws:iam::761018879361:user/yunju"
  ] # 키 사용자 권한
}

data "aws_subnet" "private_subnets" {
  count = length(var.private_subnets_ids)

  id = var.private_subnets_ids[count.index]
}

module "efs" {
  tags = {
    Name = "project-efs"
  }

  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = "project_efs"
  creation_token = "efs-token-for-project" 
  encrypted      = true
  kms_key_arn    = module.efs_kms.key_arn

  # Mount targets / security group
  mount_targets = {
    "ap-northeast-2a" = {
      subnet_id = var.public_subnets_ids[0]
    }
    "ap-northeast-2c" = {
      subnet_id = var.public_subnets_ids[1]
    }
  }
  security_group_description = "EFS security group"
  security_group_vpc_id      = var.vpc_id

  # 보안 그룹 규칙을 private subnet CIDR 블록으로 설정
  security_group_rules = {
    vpc = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      protocol = "tcp"
      from_port = 2049
      to_port = 2049
      cidr_blocks = [for subnet in data.aws_subnet.private_subnets : subnet.cidr_block]
    }
  }
}
