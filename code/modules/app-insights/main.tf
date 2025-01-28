resource "azurerm_application_insights" "main" {
  name                = "${var.prefix}appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.law_workspace_id
  application_type    = "web"
}
