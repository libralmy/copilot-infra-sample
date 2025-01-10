output "keyvault_name" {
  value = azurerm_key_vault.main.name
}

output "keyvault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "keyvault_id" {
  value = azurerm_key_vault.main.id
}
