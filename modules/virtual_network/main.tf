# ==============================================================================
# ENTERPRISE VIRTUAL NETWORK & SUBNET MODULE
# Pattern: for_each over subnets + dynamic "delegation" for PaaS services
# ==============================================================================

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  private_endpoint_network_policies             = try(each.value.private_endpoint_network_policies, "Enabled")
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)
  service_endpoints                             = try(each.value.service_endpoints, [])

  dynamic "delegation" {
    for_each = try(each.value.delegations, [])

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_name
        actions = try(delegation.value.actions, ["Microsoft.Network/virtualNetworks/subnets/action"])
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = {
    for k, v in var.subnets : k => v.network_security_group_id
    if v.network_security_group_id != null
  }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = each.value
}
