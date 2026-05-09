data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.sku_name
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  enable_rbac_authorization   = var.enable_rbac_authorization

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = lookup(network_acls.value, "ip_rules", [])
      virtual_network_subnet_ids = lookup(network_acls.value, "virtual_network_subnet_ids", [])
    }
  }

  tags = var.tags
}

# Access policies (only used when enable_rbac_authorization = false)
resource "azurerm_key_vault_access_policy" "this" {
  for_each = var.enable_rbac_authorization ? {} : { for p in var.access_policies : p.object_id => p }

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.object_id

  key_permissions         = lookup(each.value, "key_permissions", [])
  secret_permissions      = lookup(each.value, "secret_permissions", [])
  certificate_permissions = lookup(each.value, "certificate_permissions", [])
}

# RBAC role assignments (only used when enable_rbac_authorization = true)
resource "azurerm_role_assignment" "this" {
  for_each = var.enable_rbac_authorization ? { for r in var.role_assignments : "${r.principal_id}-${r.role_definition_name}" => r } : {}

  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

# Optional: Pre-populate secrets
resource "azurerm_key_vault_secret" "this" {
  for_each = { for s in var.secrets : s.name => s }

  name         = each.value.name
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this.id
  content_type = lookup(each.value, "content_type", null)
  tags         = var.tags

  depends_on = [
    azurerm_key_vault_access_policy.this,
    azurerm_role_assignment.this
  ]
}

# Optional: Private endpoint
resource "azurerm_private_endpoint" "this" {
  count = var.private_endpoint != null ? 1 : 0

  name                = "pe-${var.key_vault_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.key_vault_name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoint.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "pdnszg-${var.key_vault_name}"
      private_dns_zone_ids = [var.private_endpoint.private_dns_zone_id]
    }
  }
}
