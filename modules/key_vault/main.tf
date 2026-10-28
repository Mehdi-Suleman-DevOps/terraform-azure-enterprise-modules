# ==============================================================================
# ENTERPRISE KEY VAULT MODULE
# Pattern: dynamic "access_policy" + dynamic "network_acls"
# ==============================================================================

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                            = var.key_vault_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.sku_name
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  enable_rbac_authorization       = var.enable_rbac_authorization
  enabled_for_disk_encryption     = true
  tags                            = var.tags

  dynamic "access_policy" {
    for_each = var.enable_rbac_authorization ? [] : var.access_policies

    content {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = access_policy.value.object_id
      key_permissions         = try(access_policy.value.key_permissions, [])
      secret_permissions      = try(access_policy.value.secret_permissions, [])
      certificate_permissions = try(access_policy.value.certificate_permissions, [])
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []

    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = try(network_acls.value.ip_rules, [])
      virtual_network_subnet_ids = try(network_acls.value.virtual_network_subnet_ids, [])
    }
  }
}
