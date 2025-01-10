resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.prefix}law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
}