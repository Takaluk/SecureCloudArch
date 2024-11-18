resource "aws_db_instance" "supplier-db" {
  identifier     = "${var.env_name}-supplier-db-instance"
  engine                 = "mariadb"
  engine_version         = "10.11"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name = var.db_subnet_group_id
  vpc_security_group_ids = [var.db_sg_id]
  username = var.db_master_username
  password = var.db_master_password
  skip_final_snapshot    = true
}


