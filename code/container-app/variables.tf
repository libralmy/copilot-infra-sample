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