variable "public_subnets_id" {
  type = list(string)
}

variable "private_subnets_id" {
  type = list(string)
}

variable "bastion_host_sg_id" {
  type = string
}
variable "nat_sg_id" {
  type = string
}
variable "web_sg_id" {
  type = string
}
variable "app_sg_id" {
  type = string
}