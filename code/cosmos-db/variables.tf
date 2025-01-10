variable "prefix" {
  type        = string
  default     = "ai-chat-tool"
  description = "Prefix of the resource name"
}
variable "resource_group_name" {
  type        = string
  default     = "rg-ai-chat-tool"
  description = "Name of the resource group"
}


variable "cosmosdb_account_location" {
  type        = string
  default     = "westus2"
  description = "Cosmos db account location"
}

variable "throughput" {
  type        = number
  default     = 400
  description = "Cosmos db database throughput"
  validation {
    condition     = var.throughput >= 400 && var.throughput <= 1000000
    error_message = "Cosmos db manual throughput should be equal to or greater than 400 and less than or equal to 1000000."
  }
  validation {
    condition     = var.throughput % 100 == 0
    error_message = "Cosmos db throughput should be in increments of 100."
  }
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
  
}

variable "vnet_id" {
  type        = string
  description = "Vnet ID"
  
}
