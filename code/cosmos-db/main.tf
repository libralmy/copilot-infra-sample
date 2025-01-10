data "azurerm_resource_group" "main" {
  name = var.resource_group_name
  
}

resource "azurerm_cosmosdb_account" "main" {
  name                       = "${var.prefix}-cosmosdb"
  location                   = data.azurerm_resource_group.main.location
  resource_group_name        = var.resource_group_name
  offer_type                 = "Standard"
  kind                       = "GlobalDocumentDB"
  automatic_failover_enabled = false
  # public_network_access_enabled = false
  geo_location {
    location          = var.cosmosdb_account_location
    failover_priority = 0
  }
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "cosmosdb-sqldb-${var.prefix}"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = var.throughput
}

resource "azurerm_cosmosdb_sql_container" "collections" {
  name                  = "Collections"
  resource_group_name   = azurerm_cosmosdb_account.main.resource_group_name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths   = ["/id"]
  partition_key_version = 1
  throughput            = var.throughput

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/idlong", "/idshort"]
  }
}


resource "azurerm_cosmosdb_sql_container" "datatypes" {
  name                  = "DataTypes"
  resource_group_name   = azurerm_cosmosdb_account.main.resource_group_name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths   = ["/id"]
  partition_key_version = 1
  throughput            = var.throughput

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/idlong", "/idshort"]
  }
}

# Network
resource "azurerm_private_endpoint" "cosmosdb_private_endpoint" {
  name                = "${var.prefix}-cosmosdb-pe"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    is_manual_connection           = false
    subresource_names              = ["sql"]
  }
}


resource "azurerm_private_dns_zone" "cosmosdb_dns" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_dns_link" {
  name                  = "${var.prefix}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.cosmosdb_dns.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "cosmosdb_a_record" {
  name                = "${var.prefix}-dns-cosmosdb"
  zone_name           = azurerm_private_dns_zone.cosmosdb_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.cosmosdb_private_endpoint.private_service_connection[0].private_ip_address]
}
