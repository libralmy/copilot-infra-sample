data "azurerm_resource_group" "main" {
  name     = var.resource_group_name
}
resource "azurerm_container_app_environment" "main" {
  name                       = "${var.prefix}-container-app-env"
  location                   = data.azurerm_resource_group.main.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.law_workspace_id
}

resource "azurerm_container_app" "main" {
  name                         = "${replace(var.prefix, "-", "")}-container-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "${replace(var.prefix, "-", "")}container"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}