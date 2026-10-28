variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "key_vault_name" { type = string }
variable "sku_name" { type = string; default = "standard" }
variable "enable_rbac_authorization" { type = bool; default = true }
variable "tags" { type = map(string); default = {} }

variable "access_policies" {
  type = list(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
  }))
  default     = []
  description = "Access policies (only used if enable_rbac_authorization is false)."
}

variable "network_acls" {
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = null
  description = "Network ACL firewall rules."
}
