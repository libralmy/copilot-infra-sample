variable "resource_group_name" {
  type        = string
  default     = "rg-ai-chat-tool"
  description = "Name of the resource group"
}

variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group"
}

variable "prefix" {
  type        = string
  default     = "ai-chat-tool"
  description = "Prefix of the resource that's combined with a random ID so name is unique in your Azure subscription."
}
