data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}
# data "azurecaf_name" "acr_name" {
#   name          = "acr-${var.prefix}"
#   resource_type = "azurerm_container_registry"
# }

# resource "azurerm_container_registry" "main" {
#   name                = data.azurecaf_name.acr_name.id
#   resource_group_name = data.azurerm_resource_group.main.name
#   location            = data.azurerm_resource_group.main.location
#   sku                 = "Basic"
#   admin_enabled       = true
# }

# Azure Container Regristry
resource "azurerm_container_registry" "main" {
  name                = "${replace(var.prefix, "-", "")}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = true
}

module "private_network" {
  source = "../private-network"
  resource_group_name = var.resource_group_name
  resource_id = azurerm_container_registry.main.id
  subnet_id = var.subnet_id
  vnet_id = var.vnet_id
  prefix = var.prefix
  resource_type = "acr"
  subresource_name = "registry"
  
}