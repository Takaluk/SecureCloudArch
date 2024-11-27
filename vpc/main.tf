module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.env_name}-vpc"
  cidr = var.cidr

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets  = [cidrsubnet(var.cidr, 8, 10), cidrsubnet(var.cidr, 8, 30)]
  private_subnets = [cidrsubnet(var.cidr, 8, 11), cidrsubnet(var.cidr, 8, 31), cidrsubnet(var.cidr, 8, 12), cidrsubnet(var.cidr, 8, 32), cidrsubnet(var.cidr, 8, 13), cidrsubnet(var.cidr, 8, 33), cidrsubnet(var.cidr, 8, 14), cidrsubnet(var.cidr, 8, 34), cidrsubnet(var.cidr, 8, 15), cidrsubnet(var.cidr, 8, 35)]

  tags = {
    Name = "${var.env_name}-vpc"
  }
}

resource "aws_route" "private_route" {
  count                  = 10
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.nat_primary_network_interface_id
}