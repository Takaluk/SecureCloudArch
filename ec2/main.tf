module "bastion_host_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "bastion-host-instance"
  ami                         = "ami-01f16b483e1b41448"
  instance_type               = "t2.micro"
  key_name                    = "public-ec2-key"
  monitoring                  = true
  vpc_security_group_ids      = [var.bastion_host_sg_id]
  subnet_id                   = var.public_subnets_id[0]
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
  vpc_security_group_ids      = [var.nat_sg_id]
  subnet_id                   = var.public_subnets_id[1]
  associate_public_ip_address = true
  source_dest_check           = false
  tags = {
    Name = "nat-instance"
  }
}

module "web_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "web-instance"
  ami                         = "ami-01f16b483e1b41448"
  instance_type               = "t2.micro"
  key_name                    = "Web-Key"
  monitoring                  = true
  vpc_security_group_ids      = [var.web_sg_id]
  count                       = 2
  subnet_id                   = var.private_subnets_id[count.index]
  associate_public_ip_address = true
  tags = {
    Name = "web-instance"
  }
}

module "app_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "app-instance"
  ami                         = "ami-01f16b483e1b41448"
  instance_type               = "t2.micro"
  key_name                    = "App-Key"
  monitoring                  = true
  vpc_security_group_ids      = [var.app_sg_id]
  count                       = 2
  subnet_id                   = var.private_subnets_id[count.index + 2] # 위 vpc 모듈에서 지정함
  associate_public_ip_address = true
  tags = {
    Name = "app-instance"
  }
}