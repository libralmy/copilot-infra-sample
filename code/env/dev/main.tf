resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = "East US"
}

module "network" {
  source              = "./network"
  resource_group_name = azurerm_resource_group.main.name
  depends_on = [ azurerm_resource_group.main ]

}

module "law" {
  source              = "../../modules/log-analystics"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = var.environment_prefix
  depends_on = [ azurerm_resource_group.main ]

}

module "storage" {
  source              = "../../modules/storage"
  resource_group_name = azurerm_resource_group.main.name
  prefix              = "${var.environment_prefix}-${var.suffix}"
  vnet_id = module.network.vnet_id
  subnet_id = module.network.subnet_id
  providers = {
    azapi = azapi
  }
  depends_on = [ module.network ]
}

module "acr" {
  source              = "../../modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = "${var.environment_prefix}-${var.suffix}"
  vnet_id = module.network.vnet_id
  subnet_id = module.network.subnet_id
  depends_on = [ module.network ]
}

module "appinsights" {
  source              = "../../modules/app-insights"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  prefix              = var.environment_prefix
  law_workspace_id    = module.law.id
  depends_on = [ module.law ]
}

# module "kv" {
#   source              = "../../modules/key-vault"
#   resource_group_name = azurerm_resource_group.main.name
#   prefix              = "${var.environment_prefix}-${var.suffix}"
#   vnet_id = module.network.vnet_id
#   subnet_id = module.network.subnet_id
#   depends_on = [ module.network ]
# }

# module "appconfig" {
#   source              = "../../modules/app-configuration"
#   resource_group_name = azurerm_resource_group.main.name
#   prefix              = "${var.environment_prefix}-${var.suffix}"
#   key_vault_id        = module.kv.keyvault_id
#   # key_vault_key_id = module.kv.keyvault_key_id
#   key_vault_identity_id = module.kv.keyvault_identity_id
#   key_vault_identity_name = module.kv.keyvault_identity_name
#   vnet_id = module.network.vnet_id
#   subnet_id = module.network.subnet_id
#   depends_on = [ module.network, module.kv ]
# }

module "cosmosdb" {
  source              = "../../modules/cosmos-db"
  resource_group_name = azurerm_resource_group.main.name
  prefix              = "${var.environment_prefix}${var.suffix}"
  throughput          = 400
  vnet_id = module.network.vnet_id
  subnet_id           = module.network.subnet_id
  depends_on = [ module.network ]
}

module "containerapp" {
  source              = "../../modules/container-app"
  resource_group_name = azurerm_resource_group.main.name
  prefix              = "${var.environment_prefix}-${var.suffix}"
  law_workspace_id    = module.law.id
  vnet_id = module.network.vnet_id
  subnet_id = module.network.subnet_id
  depends_on = [ module.network, module.law ]
}
data "azurerm_container_app_environment" "main" {
  name                = module.containerapp.cae_name
  resource_group_name = azurerm_resource_group.main.name
}
data "azurerm_client_config" "current" {}

resource "azapi_resource" "storagemount" {
  type = "Microsoft.App/managedEnvironments@2024-03-01"
  name = "emily-container-app-env-mount"
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.main.name}"
  schema_validation_enabled = false

  location = azurerm_resource_group.main.location
  body = {
    properties = merge({
      appLogsConfiguration = {
        connectionString = module.appinsights.appinsights_connection_string
      }
      appLogsConfiguration = {
        "destination" = "log-analytics"
        logAnalyticsConfiguration = {
          "customerId" = module.law.workspace_id
          "sharedKey" = module.law.sharedkey
        }
      }
      infrastructureResourceGroup = azurerm_resource_group.main.name
      kedaConfiguration = {
      }
    }
  )
}
}
resource "azapi_resource" "menv_storage" {
  type = "Microsoft.App/managedEnvironments/storages@2024-03-01"
  body = {
    properties = {
      azureFile = {
        accessMode  = "ReadWrite"
        accountKey  = module.storage.storage_primary_access_key
        accountName = module.storage.storage_account_name
        shareName   = module.storage.fileshare
      }
    }
  }
  parent_id = azapi_resource.storagemount.id
  name                      = "menvstorage"
  schema_validation_enabled = false
}

resource "azapi_resource" "menv_storage_azurerm" {
  type = "Microsoft.App/managedEnvironments/storages@2024-03-01"
  body = {
    properties = {
      azureFile = {
        accessMode  = "ReadWrite"
        accountKey  = module.storage.storage_primary_access_key
        accountName = module.storage.storage_account_name
        shareName = module.storage.fileshare_azurerm
      }
    }
  }
  parent_id = azapi_resource.storagemount.id
  name                      = "menvstorageazurerm"
  schema_validation_enabled = false
}

# az containerapp show \
#   --name catestavm \
#   --resource-group atestdev-rg-infra-sample \
#   --output yaml > app.yaml

module "containerapp-storagemount" {
  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "0.3.0"
  name = "catestavm"
  container_app_environment_resource_id = azapi_resource.storagemount.id
  resource_group_name = azurerm_resource_group.main.name
  revision_mode = "Single"
  template = {
        containers = [
          {
            name   = "hello-world"
            image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            memory = "1Gi"
            cpu    = 0.5
            volume_mounts = [
              {
                name = "cafileshare"
                path = "/usr/myfileshare"
              }
            ]
          }
        ],
        volumes = [
          {
            name         = "cafileshare"
            storage_name = azapi_resource.menv_storage_azurerm.name
            storage_type = "AzureFile"
          }
      ]
  }
  ingress = {
    allow_insecure_connections = false
    target_port                = 80
    external_enabled           = true

    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
  
}

# module "staticsite" {
#   source             = "Azure/avm-res-web-staticsite/azurerm"
#   version = "0.4.0"

#   enable_telemetry = false

#   name                = "stapp-${var.environment_prefix}-${var.suffix}"
#   resource_group_name = azurerm_resource_group.main.name
#   location = "global"

#   app_settings = {

#   }

# }