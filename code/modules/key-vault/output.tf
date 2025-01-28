output "keyvault_name" {
  value = azurerm_key_vault.main.name
}

output "keyvault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "keyvault_id" {
  value = azurerm_key_vault.main.id
}

output "keyvault_identity_id" {
  value = azurerm_user_assigned_identity.kv_identity.id
  
}

output "keyvault_identity_name" {
  value = azurerm_user_assigned_identity.kv_identity.name
  
}

# output "keyvault_key_id" {
#   value = azurerm_key_vault_key.generated.id
# }