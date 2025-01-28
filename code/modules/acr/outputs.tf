output "acr_login_server" {
  value       = azurerm_container_registry.main.login_server
  description = "The URL that can be used to log into the Azure Container Registry (ACR)"
}

output "acr_admin_username" {
  value       = azurerm_container_registry.main.admin_username
  description = "The username that can be used to log into the Azure Container Registry (ACR)"
}

output "acr_admin_password" {
  value       = azurerm_container_registry.main.admin_password
  description = "The password that can be used to log into the Azure Container Registry (ACR)"
  sensitive   = true
}
