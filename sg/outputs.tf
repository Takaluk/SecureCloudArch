output "bastion_host_sg_id" {
  value = module.bastion_sg.security_group_id
}

output "nat_sg_id" {
  value = module.nat_sg.security_group_id
}

output "web_sg_id" {
  value = module.web_sg.security_group_id
}

output "app_sg_id" {
  value = module.app_sg.security_group_id
}

output "security_group_id" {
  value = module.efs-sg.security_group_id
}