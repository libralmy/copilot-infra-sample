
output "appinsights_connection_string" {
  description = "The Connection String of the Application Insights"
  value       = azurerm_application_insights.main.connection_string
}
output "appinsights_instrumentation_key" {
  description = "The Instrumentation Key of the Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}
