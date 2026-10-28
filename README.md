# 🏛️ Terraform Azure Enterprise Reusable Modules

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Provider%20~%3E%203.80-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![Security](https://img.shields.io/badge/Security-Checkov%20%7C%20tfsec-00C853?style=for-the-badge&logo=shieldsdotio&logoColor=white)](#)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](#)

> **Architected by Mehdi Suleman**  
> *Senior DevSecOps & Enterprise Automation Engineer*  
> Email: [mailtomehdi133@gmail.com](mailto:mailtomehdi133@gmail.com) | GitHub: [@Mehdi-Suleman-DevOps](https://github.com/Mehdi-Suleman-DevOps)

---

## 🌟 Architectural Philosophy: Advanced Patterns

In enterprise cloud platform engineering, hardcoded resources and brittle `count` indices cause disastrous accidental resource destructions during configuration shifts. This repository provides **production-hardened, reusable Terraform modules** implementing the gold standard trio of Infrastructure as Code:

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             THE ENTERPRISE TRIO                                  │
├───────────────────┬──────────────────────────────────────────────────────────────┤
│ 1. for_each       │ Deterministic key-based resource addressability.             │
│                   │ Adding/removing items NEVER causes adjacent recreations.     │
├───────────────────┼──────────────────────────────────────────────────────────────┤
│ 2. map(object)    │ Type-safe, self-documenting configuration contracts.         │
│                   │ Validates ports, CIDRs, and naming conventions at plan time. │
├───────────────────┼──────────────────────────────────────────────────────────────┤
│ 3. dynamic blocks │ Reusable single resource definitions that dynamically expand │
│                   │ nested sub-blocks (security rules, delegations, ACLs).       │
└───────────────────┴──────────────────────────────────────────────────────────────┘
```

---

## 📦 Module Catalog

| Module | Core Features & Patterns | Directory |
| :--- | :--- | :--- |
| **Network Security Group** | `for_each` over NSG map + `dynamic "security_rule"` iterating over custom nested rules map with priority, port ranges, and protocols. | [`modules/network_security_group`](./modules/network_security_group) |
| **Virtual Network & Subnets** | `for_each` over subnets + `dynamic "delegation"` for AKS/App Service + NSG association map. | [`modules/virtual_network`](./modules/virtual_network) |
| **Azure Key Vault** | `for_each` KV creation + `dynamic "access_policy"` + `dynamic "network_acls"` (IP rules & VNet subnet restrictions). | [`modules/key_vault`](./modules/key_vault) |
| **AKS Cluster** | `dynamic "default_node_pool"` + `dynamic "identity"` + separate `for_each` multi-node pool module with auto-scaling. | [`modules/aks_cluster`](./modules/aks_cluster) |

---

## 🚀 Quick Start Example

Consume all modules with a single root orchestration file:

```hcl
# main.tf
module "nsg" {
  source              = "./modules/network_security_group"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  nsg_configs = {
    "nsg-aks-nodes" = {
      rules = {
        "allow-https-inbound" = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["443", "8443"]
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow HTTPS traffic from corporate network"
        }
      }
    }
  }
}
```

See the full working implementation in [`examples/complete-enterprise-landing-zone`](./examples/complete-enterprise-landing-zone).
