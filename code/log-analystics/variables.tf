variable "resource_group_name" {
  description = "The name of the resource group in which the Log Analytics Workspace should be created."   
  type = string
}

variable "location" {
  description = "The location/region where the Log Analytics Workspace should be created."
  type = string
}

variable "prefix" {
  description = "A prefix to add to the Log Analytics Workspace name."
  type = string
  
}

variable "sku" {
  description = "The SKU (pricing tier) of the Log Analytics Workspace."
  type = string
  default = "PerGB2018"
}

variable "retention_in_days" {
  description = "The retention period in days of the logs that are being sent to the Log Analytics Workspace."
  type = number
  default = 30
}