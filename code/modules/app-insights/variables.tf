variable "prefix" {
  type        = string
  description = "Prefix of the resource that's combined with a random ID so name is unique in your Azure subscription."
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group"
}

variable "law_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace"
  
}