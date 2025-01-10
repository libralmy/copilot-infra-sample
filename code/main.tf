resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = "East US"
}

module "law" {
  source              = "./log-analystics"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = var.environment_prefix
}

module "storage" {
  source              = "./storage"
  resource_group_name = azurerm_resource_group.main.name
  prefix              = "${var.environment_prefix}-${var.suffix}"
  
}

module "acr" {
  source              = "./acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = "${var.environment_prefix}-${var.suffix}"
  
}

module "appinsights" {
  source              = "./app-insights"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = var.environment_prefix
  law_workspace_id    = module.law.id
}