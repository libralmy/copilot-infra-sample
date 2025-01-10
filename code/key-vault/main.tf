data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# generate a random string for the key vault name
resource "random_id" "key_vault_name" {
  byte_length = 8
}

resource "azurerm_key_vault" "main" {
  name                = "kv-${data.azurerm_resource_group.main.name}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"
  tags     = {}
}

resource "azurerm_key_vault_access_policy" "creator" {
  key_vault_id = azurerm_key_vault.main.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge"
  ]

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Purge"
  ]
}
