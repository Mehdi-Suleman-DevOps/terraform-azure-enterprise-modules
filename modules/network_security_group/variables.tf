variable "resource_group_name" {
  type        = string
  description = "Name of the target resource group."
}

variable "location" {
  type        = string
  description = "Azure region where the NSGs will be deployed."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Default tags applied to all NSGs."
}

variable "nsg_configs" {
  type = map(object({
    tags = optional(map(string), {})
    rules = map(object({
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
      description                  = optional(string)
    }))
  }))
  description = "Map of NSG definitions with nested security rules."
}
