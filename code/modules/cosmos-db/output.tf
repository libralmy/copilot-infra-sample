
output "cosmosdb_endpoint" {
  description = "The endpoint of the CosmosDB Account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmosdb_primary_key" {
  description = "The primary master key of the CosmosDB Account"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmosdb_connectionstrings" {
   value = "AccountEndpoint=${azurerm_cosmosdb_account.main.endpoint};AccountKey=${azurerm_cosmosdb_account.main.primary_key};"
   sensitive   = true
}

output "cosmosdb_database" {
  description = "The name of the CosmosDB Database"
  value       = azurerm_cosmosdb_sql_database.main.name
}
