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

resource "azurerm_private_endpoint" "app_config_private_endpoint" {
  name                = "${replace(var.prefix, "-", "")}-appconfig-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${replace(var.prefix, "-", "")}-appconfig-psc"
    private_connection_resource_id = azurerm_app_configuration.main.id
    is_manual_connection           = false
    subresource_names              = ["configurationStores"]
  }
}

resource "azurerm_private_dns_zone" "app_config_dns" {
  name                = "privatelink.azconfig.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "app_config_dns_link" {
  name                  = "${replace(var.prefix, "-", "")}-appconfig-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.app_config_dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "app_config_a_record" {
  name                = "${replace(var.prefix, "-", "")}-appconfig"
  zone_name           = azurerm_private_dns_zone.app_config_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.app_config_private_endpoint.private_service_connection[0].private_ip_address]
}