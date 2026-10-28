output "nsg_ids" {
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
  description = "Map of NSG names to their Azure Resource IDs."
}

output "nsg_names" {
  value       = [for k, v in azurerm_network_security_group.nsg : v.name]
  description = "List of created NSG names."
}
