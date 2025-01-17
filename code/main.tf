resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = "East US"
}

module "network" {
  source              = "./network"
  resource_group_name = azurerm_resource_group.main.name

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
  vnet_id = module.network.vnet_id
  subnet_id = module.network.subnet_id
  providers = {
    azapi = azapi
  }
}

module "acr" {
  source              = "./acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = "${var.environment_prefix}-${var.suffix}"
  vnet_id = module.network.vnet_id
  subnet_id = module.network.subnet_id
}

module "appinsights" {
  source              = "./app-insights"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = var.environment_prefix
  law_workspace_id    = module.law.id
}

module "kv" {
  source              = "./key-vault"
  resource_group_name = azurerm_resource_group.main.name
  prefix              = "${var.environment_prefix}-${var.suffix}"
  vnet_id = module.network.vnet_id
  subnet_id = module.network.subnet_id
}

module "appconfig" {
  source              = "./app-configuration"
  resource_group_name = azurerm_resource_group.main.name
  prefix              = "${var.environment_prefix}-${var.suffix}"
  key_vault_id        = module.kv.keyvault_id
  # key_vault_key_id = module.kv.keyvault_key_id
  key_vault_identity_id = module.kv.keyvault_identity_id
  key_vault_identity_name = module.kv.keyvault_identity_name
  vnet_id = module.network.vnet_id
  subnet_id = module.network.subnet_id
  depends_on = [ module.kv ]
}

module "cosmosdb" {
  source              = "./cosmos-db"
  resource_group_name = azurerm_resource_group.main.name
  prefix              = "${var.environment_prefix}${var.suffix}"
  throughput          = 400
  vnet_id = module.network.vnet_id
  subnet_id           = module.network.subnet_id
}

module "containerapp" {
  source              = "./container-app"
  resource_group_name = azurerm_resource_group.main.name
  prefix              = "${var.environment_prefix}-${var.suffix}"
  law_workspace_id    = module.law.id
  vnet_id = module.network.vnet_id
  subnet_id = module.network.subnet_id
  
}