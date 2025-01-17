terraform {
  required_version = ">=1.6.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.14.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.14.0, < 3.0.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id = var.subscription_id
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
}

provider "azapi" {

  subscription_id = var.subscription_id
}