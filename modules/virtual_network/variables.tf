variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "vnet_name" {
  type        = string
  description = "Virtual network name."
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the VNet."
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    service_endpoints                             = optional(list(string), [])
    network_security_group_id                     = optional(string, null)
    delegations = optional(list(object({
      name         = string
      service_name = string
      actions      = optional(list(string))
    })), [])
  }))
  description = "Map of subnets to create within the VNet."
}
