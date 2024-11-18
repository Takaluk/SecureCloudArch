variable "env_name" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}
variable "db_sg_id" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_master_username" {
  type = string
}
variable "db_master_password" {
  type = string
}
variable "db_subnet_group_id" {
  type = string
}