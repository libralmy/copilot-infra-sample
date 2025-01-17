variable "resource_group_name" {
  type        = string
  description = "Resource Group for managing for all deployments"
  
}

variable "law_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID"
  
}

variable "prefix" {
  type        = string
  description = "Prefix for all resources"
  
}

variable "vnet_id" {
  type        = string
  description = "VNET ID"
  
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
  
}