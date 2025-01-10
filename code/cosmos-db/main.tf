# data "azurerm_resource_group" "main" {
#   name = var.resource_group_name
# }
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
  name                = "acr${replace(var.prefix, "-", "")}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
  admin_enabled       = true
}
