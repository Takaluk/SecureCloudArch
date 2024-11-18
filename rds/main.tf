# RDS Subnet Group 생성

resource "aws_db_subnet_group" "db-subnet-group" {
  name = "${var.env_name}-db-subnet-group"
  subnet_ids = var.private_subnets
  tags = {
    "Name" = "db-subnet-group"
  }
}

resource "aws_db_instance" "maria-db" {
  identifier     = "${var.env_name}-maria-db-instance"
  engine                 = "mariadb"
  engine_version         = "10.11"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
  vpc_security_group_ids = [var.db_sg_id]
  db_name                = var.db_name
  username = var.db_master_username
  password = var.db_master_password
  skip_final_snapshot    = true
}


