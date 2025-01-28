data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_key_vault" "main" {
  name                = "${replace(var.prefix, "-", "")}kv"
  location                   = data.azurerm_resource_group.main.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
    ]

    secret_permissions = [
      "Set",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"

    virtual_network_subnet_ids = [var.subnet_id]
  }
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


resource "azurerm_user_assigned_identity" "kv_identity" {
  name                = "kv-${var.prefix}-identity"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_key_vault_access_policy" "server" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.kv_identity.principal_id

  key_permissions    = ["Get", "UnwrapKey", "WrapKey" ]
  secret_permissions = ["Get"]
}

resource "azurerm_private_endpoint" "keyvault_private_endpoint" {
  name                = "${var.prefix}-keyvault-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-keyvault-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

resource "azurerm_private_dns_zone" "keyvault_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_dns_link" {
  name                  = "${var.prefix}-keyvault-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "keyvault_a_record" {
  name                = "${var.prefix}-keyvault"
  zone_name           = azurerm_private_dns_zone.keyvault_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.keyvault_private_endpoint.private_service_connection[0].private_ip_address]
}


# resource "azurerm_key_vault_access_policy" "client" {
#   key_vault_id = azurerm_key_vault.main.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = data.azurerm_client_config.current.object_id

#   key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
#   secret_permissions = ["Get"]
# }

# resource "azurerm_key_vault_key" "generated" {
#   name         = "generated-certificate"
#   key_vault_id = azurerm_key_vault.main.id
#   key_type     = "RSA"
#   key_size     = 2048

#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]

#   # rotation_policy {
#   #   automatic {
#   #     time_before_expiry = "P30D"
#   #   }

#   #   expire_after         = "P90D"
#   #   notify_before_expiry = "P29D"
#   # }
# }