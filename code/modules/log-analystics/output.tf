output "name" {
  value = azurerm_log_analytics_workspace.main.name
  
}

output "id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.main.workspace_id
}


output "sharedkey" {
  value = azurerm_log_analytics_workspace.main.primary_shared_key
}