terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-enterprise-landingzone-prod"
  location = "eastus2"
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "Mehdi-Suleman-DevOps"
  }
}

# 1. NSG Module with for_each and dynamic security_rule
module "network_security_groups" {
  source              = "../../modules/network_security_group"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = azurerm_resource_group.rg.tags

  nsg_configs = {
    "nsg-aks-ingress" = {
      rules = {
        "allow-https-ingress" = {
          priority                = 100
          direction               = "Inbound"
          access                  = "Allow"
          protocol                = "Tcp"
          source_port_range       = "*"
          destination_port_ranges = ["443", "80"]
          source_address_prefix   = "Internet"
          destination_address_prefix = "*"
          description             = "Public HTTPS ingress"
        }
      }
    }
    "nsg-backend-db" = {
      rules = {
        "allow-sql-from-aks" = {
          priority                = 110
          direction               = "Inbound"
          access                  = "Allow"
          protocol                = "Tcp"
          source_port_range       = "*"
          destination_port_range  = "1433"
          source_address_prefix   = "10.100.1.0/24"
          destination_address_prefix = "*"
          description             = "Private SQL access from AKS subnet only"
        }
      }
    }
  }
}

# 2. VNet Module with dynamic subnet delegations
module "vnet" {
  source              = "../../modules/virtual_network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "vnet-prod-workload"
  address_space       = ["10.100.0.0/16"]
  tags                = azurerm_resource_group.rg.tags

  subnets = {
    "snet-aks-nodes" = {
      address_prefixes          = ["10.100.1.0/24"]
      network_security_group_id = module.network_security_groups.nsg_ids["nsg-aks-ingress"]
    }
    "snet-private-endpoints" = {
      address_prefixes          = ["10.100.2.0/24"]
      network_security_group_id = module.network_security_groups.nsg_ids["nsg-backend-db"]
    }
  }
}

# 3. Key Vault with RBAC & dynamic network ACLs
module "key_vault" {
  source                    = "../../modules/key_vault"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  key_vault_name            = "kv-prod-enterprise-01"
  enable_rbac_authorization = true
  tags                      = azurerm_resource_group.rg.tags

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = [module.vnet.subnet_ids["snet-aks-nodes"]]
  }
}
