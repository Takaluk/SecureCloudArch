variable "vpc_id" {
  type = string
}

variable "public_subnets_ids" {
  type = list(string)
}


variable "private_subnets_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}