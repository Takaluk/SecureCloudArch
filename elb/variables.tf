# vpcid, subnets, 
variable "vpc_id" {
  type = string
}

variable "public_subnets_id" {
  type = list(string)
}

variable "web11_ec2_id" {
  type = string
}
variable "web31_ec2_id" {
  type = string
}