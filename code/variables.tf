variable "environment_prefix" {
  description = "The suffix to add to the resource group name."
  type = string
  default = "dev-"
  
}
variable "suffix" {
  description = "The suffix to add to the resource group name."
  type = string
  default = "emily"
  
}

variable "subscription_id" {
  description = "The subscription ID in which the Log Analytics Workspace should be created."
  type = string
  default = "0dd281b7-e4d8-4f02-a4b4-18739bb6d62b"
  
}