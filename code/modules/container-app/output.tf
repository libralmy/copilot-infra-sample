output "ca_env_static_ip" {
  value = azurerm_container_app_environment.main.static_ip_address  
  
}

output "cae_name" {
  value = azurerm_container_app_environment.main.name
}
