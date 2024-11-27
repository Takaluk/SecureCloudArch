# vpcid, subnets, 
variable "vpc_id" {
  type = string
}

variable "public_subnets_id" {
  type = list(string)
}
variable "private_subnets_id" {
  type = list(string)
}

variable "web11_ec2_id" {
  type = string
}
variable "web31_ec2_id" {
  type = string
}

variable "app12_ec2_id" {
  type = string
}
variable "app32_ec2_id" {
  type = string
}
variable "app13_ec2_id" {
  type = string
}
variable "app33_ec2_id" {
  type = string
}
variable "web_sg_id" {
  type = string
}