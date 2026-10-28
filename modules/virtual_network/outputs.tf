output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "ID of the created VNet."
}

output "subnet_ids" {
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
  description = "Map of subnet names to their Azure Resource IDs."
}
