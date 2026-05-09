variable "key_vault_name" {
  description = "Name of the Key Vault (globally unique, 3-24 alphanumeric chars and hyphens)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "sku_name" {
  description = "SKU for the Key Vault: 'standard' or 'premium'"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be 'standard' or 'premium'."
  }
}

variable "soft_delete_retention_days" {
  description = "Retention days for soft-deleted objects (7–90)"
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection (cannot be disabled once enabled)"
  type        = bool
  default     = true
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for data plane auth instead of access policies"
  type        = bool
  default     = true
}

variable "access_policies" {
  description = "Access policies (used only when enable_rbac_authorization = false)"
  type = list(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
  }))
  default = []
}

variable "role_assignments" {
  description = "RBAC role assignments (used only when enable_rbac_authorization = true)"
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = []
}

variable "network_acls" {
  description = "Network ACL configuration. Set default_action to 'Deny' to restrict access."
  type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "private_endpoint" {
  description = "Private endpoint configuration"
  type = object({
    subnet_id            = string
    private_dns_zone_id  = optional(string, null)
  })
  default = null
}

variable "secrets" {
  description = "Initial secrets to create in the Key Vault"
  type = list(object({
    name         = string
    value        = string
    content_type = optional(string, null)
  }))
  default   = []
  sensitive = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
