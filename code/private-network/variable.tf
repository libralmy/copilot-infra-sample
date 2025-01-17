variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."    
  type = string
  
}

variable "resource_id" {
  type = string
}

variable "subnet_id" {
  description = "The ID of the subnet in which the private endpoint will be created."
  type = string
  
}

variable "vnet_id" {
  description = "The ID of the virtual network in which the private DNS zone will be linked."
  type = string 
  
}

variable "prefix" {
  description = "The prefix to use for all resources in this module."
  type = string
  
}

variable "resource_type" {
  description = "The type of resource to create."
  type = string
  default = "azure"
  
}

variable "subresource_name" {
    description = "The name of the subresource to connect to the private endpoint."
    type = string
    default = "configurationStores"
}

variable "request_pe" {
  description = "Whether or not to create the private endpoint."
  type = bool
  default = true
}

variable "static_ip_address" {
  description = "The static IP address to use for the private endpoint."
  type = string
  default = ""
  
}