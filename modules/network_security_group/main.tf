# ==============================================================================
# ENTERPRISE NETWORK SECURITY GROUP MODULE
# Pattern: for_each over map of NSGs + dynamic "security_rule" over rules map
# ==============================================================================

resource "azurerm_network_security_group" "nsg" {
  for_each = var.nsg_configs

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, try(each.value.tags, {}))

  dynamic "security_rule" {
    for_each = each.value.rules

    content {
      name                         = security_rule.key
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = try(security_rule.value.source_port_range, null)
      source_port_ranges           = try(security_rule.value.source_port_ranges, null)
      destination_port_range       = try(security_rule.value.destination_port_range, null)
      destination_port_ranges      = try(security_rule.value.destination_port_ranges, null)
      source_address_prefix        = try(security_rule.value.source_address_prefix, null)
      source_address_prefixes      = try(security_rule.value.source_address_prefixes, null)
      destination_address_prefix   = try(security_rule.value.destination_address_prefix, null)
      destination_address_prefixes = try(security_rule.value.destination_address_prefixes, null)
      description                  = try(security_rule.value.description, "Managed by Terraform")
    }
  }
}
