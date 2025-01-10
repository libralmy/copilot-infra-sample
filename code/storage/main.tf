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
  network_rules {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }
  tags = {
    environment = "staging"
  }
}

