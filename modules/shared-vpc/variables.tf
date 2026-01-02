# modules/shared-vpc/variables.tf
# Variables for VPC / Shared VPC module

############################################
# Core
############################################

variable "host_project_id" {
  description = "Project ID where the VPC will be created (Host Project)"
  type        = string

  validation {
    condition     = length(var.host_project_id) > 0
    error_message = "host_project_id cannot be empty."
  }
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "callzen-vpc"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.network_name))
    error_message = "Network name must use lowercase letters, numbers, and hyphens."
  }
}

############################################
# Network Behavior
############################################

variable "routing_mode" {
  description = "Network-wide routing mode"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "routing_mode must be REGIONAL or GLOBAL."
  }
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes"
  type        = number
  default     = 1460

  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "MTU must be between 1300 and 8896."
  }
}

variable "description" {
  description = "Description of the VPC network"
  type        = string
  default     = "VPC network for Callzen infrastructure (Shared VPC ready)"
}

############################################
# Shared VPC (Disabled by default)
############################################

variable "enable_shared_vpc_host" {
  description = "Enable Shared VPC host project (requires org-level permissions)"
  type        = bool
  default     = false
}

variable "service_project_ids" {
  description = "Service projects to attach when Shared VPC is enabled"
  type        = list(string)
  default     = []
}
