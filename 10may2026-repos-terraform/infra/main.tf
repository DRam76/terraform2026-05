# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# ─── Resource Group ───────────────────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags = var.tags
}

# ─── VNet Module ──────────────────────────────────────────────────────────────

module "vnet" {
  source = "./modules/azure-vnet"

  vnet_name           = "vnet-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags

  subnets = [
    {
      name             = "snet-app"
      address_prefixes = ["10.0.1.0/24"]
      create_nsg       = true
    },
    {
      name             = "snet-data"
      address_prefixes = ["10.0.2.0/24"]
      create_nsg       = true
    },
    {
      # Dedicated subnet for Key Vault private endpoint
      name             = "snet-privateendpoints"
      address_prefixes = ["10.0.3.0/27"]
      create_nsg       = false
    }
  ]
}

# ─── Key Vault Module ─────────────────────────────────────────────────────────
