# variables.tf
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
  default     = "uksouth"
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "initial_secrets" {
  description = "Initial secrets to seed the Key Vault with"
  type = list(object({
    name         = string
    value        = string
    content_type = optional(string, null)
  }))
  default   = []
  sensitive = true
}
