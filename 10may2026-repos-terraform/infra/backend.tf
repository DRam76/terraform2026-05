terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "teraftfstateprod001"
    container_name       = "tfstate-dev"
#    key                  = "infra-${var.environment}.tfstate"
    key                  = "infra-dev.tfstate"
    use_azuread_auth = true   # ← skips listKeys entirely
    #Add Grant the SPN the Required Role -Assign the Storage Blob Data Contributor role
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}
