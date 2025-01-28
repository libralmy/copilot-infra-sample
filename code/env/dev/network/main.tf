data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name


}

resource "azurerm_subnet" "main" {
  name                 = "${var.resource_group_name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
#   private_endpoint_network_policies = Enabled
#    delegation {
#         name = "delegation"

#         service_delegation {
#         name    = "Microsoft.ContainerInstance/containerGroups"
#         actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
#         }
#     }
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.ContainerRegistry"]
}
