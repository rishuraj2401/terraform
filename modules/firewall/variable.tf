# modules/firewall/variables.tf
# Variables for Firewall Rules Module

############################################
# Core
############################################

variable "project_id" {
  description = "The GCP project ID where firewall rules will be created"
  type        = string
}

variable "network_self_link" {
  description = "Self-link of the VPC network"
  type        = string
}

############################################
# Firewall Rule Priority
############################################

variable "default_priority" {
  description = "Default priority for firewall rules (lower number = higher priority)"
  type        = number
  default     = 1000

  validation {
    condition     = var.default_priority >= 0 && var.default_priority <= 65535
    error_message = "Firewall priority must be between 0 and 65535."
  }
}

############################################
# Internal Traffic
############################################

variable "enable_internal_traffic" {
  description = "Enable rule to allow all internal traffic within VPC"
  type        = bool
  default     = true
}

variable "internal_source_ranges" {
  description = "CIDR ranges allowed for internal traffic"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

############################################
# Kubernetes API
############################################

variable "k8s_api_port" {
  description = "Port for Kubernetes API server"
  type        = number
  default     = 6443
}

variable "k8s_api_source_ranges" {
  description = "CIDR ranges allowed to access Kubernetes API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

############################################
# IAP SSH
############################################

variable "enable_iap_ssh" {
  description = "Enable SSH access via Google IAP"
  type        = bool
  default     = true
}

variable "iap_source_ranges" {
  description = "Google IAP IP ranges"
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

############################################
# Load Balancer Health Checks
############################################

variable "enable_health_checks" {
  description = "Enable load balancer health check firewall rules"
  type        = bool
  default     = true
}

variable "health_check_ports" {
  description = "Ports used by load balancer health checks"
  type        = list(string)
  default     = ["80", "443", "8080"]
}

variable "health_check_source_ranges" {
  description = "GCP health check source ranges"
  type        = list(string)
  default = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
}

############################################
# Firewall Logging
############################################

variable "enable_firewall_logs" {
  description = "Enable firewall rule logging"
  type        = bool
  default     = true
}

variable "firewall_log_metadata" {
  description = "Metadata to include in firewall logs"
  type        = string
  default     = "INCLUDE_ALL_METADATA"

  validation {
    condition     = contains(["EXCLUDE_ALL_METADATA", "INCLUDE_ALL_METADATA"], var.firewall_log_metadata)
    error_message = "firewall_log_metadata must be EXCLUDE_ALL_METADATA or INCLUDE_ALL_METADATA."
  }
}
