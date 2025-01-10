data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "key_vault_identity" {
  name = var.key_vault_identity_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_app_configuration" "main" {
  name                = "${replace(var.prefix, "-", "")}app-config"
  resource_group_name        = var.resource_group_name
  location                   = data.azurerm_resource_group.main.location
  sku                        = "standard"
  local_auth_enabled         = true
  public_network_access      = "Enabled"
  purge_protection_enabled   = false
  soft_delete_retention_days = 1

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.key_vault_identity.id,
    ]
  }

  encryption {
    # key_vault_key_identifier = var.key_vault_key_id
    identity_client_id       = data.azurerm_user_assigned_identity.key_vault_identity.client_id
  }

  tags = {
    environment = "development"
  }

}