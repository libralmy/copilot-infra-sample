variable "resource_group_name" {
  type        = string
  description = "Resource Group for managing for all deployments"
}

variable "prefix" {
  type        = string
  description = "Prefix of the resource that's combined with a random ID so name is unique in your Azure subscription."
  
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
  
}

variable "vnet_id" {
  type        = string
  description = "Vnet ID"
  
}