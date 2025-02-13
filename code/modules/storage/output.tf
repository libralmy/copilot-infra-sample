output "storage_account_name" {
  value = azurerm_storage_account.main.name
}
output "storage_account_id" {
  value = azurerm_storage_account.main.id
}
output "storage_primary_endpoint" {
  value = azurerm_storage_account.main.primary_blob_endpoint
}
output "storage_primary_access_key" {
  sensitive = true
  value     = azurerm_storage_account.main.primary_access_key
}
output "fileshare" {
  value = azapi_resource.share.name
}

output "fileshare_azurerm" {
  value = azurerm_storage_share.this.name
}