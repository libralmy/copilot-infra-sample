variable "resource_group_name" {
  type        = string

  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group"
}

variable "prefix" {
  type        = string
  default     = "dev"
  description = "Prefix of the resource that's combined with a random ID so name is unique in your Azure subscription."
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet"
  
}

variable "vnet_id" {
  type        = string
  description = "ID of the virtual network"
  
}