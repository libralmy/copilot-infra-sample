data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}
resource "azurerm_storage_account" "main" {
  name                = "${replace(var.prefix, "-", "")}storage"
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  shared_access_key_enabled = true
  network_rules {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }
  tags = {
    environment = "staging"
  }
}


resource "azapi_resource" "queues" {
  type = "Microsoft.Storage/storageAccounts/queueServices/queues@2023-05-01"
  name = "testqueue"
  # body = jsonencode({
  #   properties = {
  #     metadata = {
  #       {customized property} = "string"
  #     }
  #   }
  # })
  parent_id                 = "${azurerm_storage_account.main.id}/queueServices/default"
  schema_validation_enabled = false

  depends_on = [ azurerm_storage_account.main ]
}

resource "azurerm_private_endpoint" "storage_queue" {
  name                = "${azurerm_storage_account.main.name}-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${azurerm_storage_account.main.name}-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }
}

resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "${var.resource_group_name}-vnet-link"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "storage" {
  name                = azurerm_storage_account.main.name
  zone_name           = azurerm_private_dns_zone.storage.name
  resource_group_name = data.azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_queue.private_service_connection[0].private_ip_address]
}

# resource "azurerm_private_endpoint" "private_endpoint" {
#   name                = "${replace(var.prefix, "-", "")}-queue-pe"
#   location            = data.azurerm_resource_group.main.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id

#   private_service_connection {
#     name                           = "${replace(var.prefix, "-", "")}-queue-psc"
#     private_connection_resource_id = azapi_resource.queues.id
#     is_manual_connection           = false
#     subresource_names              = ["queue"]
#   }
#   depends_on = [ azapi_resource.queues ]
# }

# resource "azurerm_private_dns_zone" "app_config_dns" {
#   name                = "privatelink.queue.io"
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "app_config_dns_link" {
#   name                  = "${replace(var.prefix, "-", "")}-queue-dns-link"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.app_config_dns.name
#   virtual_network_id    = var.vnet_id
# }

# resource "azurerm_private_dns_a_record" "app_config_a_record" {
#   name                = "${replace(var.prefix, "-", "")}-queue"
#   zone_name           = azurerm_private_dns_zone.app_config_dns.name
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address]
# }