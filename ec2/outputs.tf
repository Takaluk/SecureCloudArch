output "nat_primary_network_interface_id" {
  value = module.nat_instance.primary_network_interface_id
}

output "web11_ec2_id"{
  value = module.web_instance[0].id
}
output "web31_ec2_id" {
  value = module.web_instance[1].id
}

output "app12_ec2_id"{
  value = module.app_instance[0].id
}
output "app32_ec2_id" {
  value = module.app_instance[1].id
}