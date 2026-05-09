output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault (used for referencing secrets)"
  value       = azurerm_key_vault.this.vault_uri
}

output "secret_ids" {
  description = "Map of secret name to secret ID"
  value       = { for k, v in azurerm_key_vault_secret.this : k => v.id }
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID of the private endpoint (if created)"
  value       = var.private_endpoint != null ? azurerm_private_endpoint.this[0].id : null
}
