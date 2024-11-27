output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnets_id" {
  value = module.vpc.public_subnets
}
output "private_subnets_id" {
  value = module.vpc.private_subnets
}
output "env_name" {
  value = var.env_name
}