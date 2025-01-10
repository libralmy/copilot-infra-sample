variable "resource_group_name" {
  type        = string
  description = "Resource Group for managing for all deployments"
  
}

variable "key_vault_id" {
  type = string
  description = "value of the key vault id"
}

variable "key_vault_identity_id" {
  type = string
  description = "value of the key vault identity id"
  
}

variable "key_vault_identity_name" {
  type = string
  description = "value of the key vault identity name"
  
}

variable "prefix" {
  type        = string
  description = "Prefix for all resources"
  
}

# variable "key_vault_key_id" {
#   type = string
#   description = "value of the key vault uri"
  
# }