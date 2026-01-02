# modules/subnet/variables.tf
# Variables for Subnet Module (Self-managed Kubernetes, existing subnet safe)

############################################
# Core Project / Network
############################################

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for subnets"
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "Region must be a valid GCP region (e.g., asia-south1)."
  }
}

variable "network_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

############################################
# Kubernetes Subnet Configuration
############################################

variable "kubernetes_subnet_name" {
  description = "Name of the Kubernetes subnet (existing or new)"
  type        = string
}

variable "kubernetes_subnet_cidr" {
  description = "Primary CIDR range for Kubernetes subnet (used only for validation & IP planning)"
  type        = string

  validation {
    condition     = can(cidrhost(var.kubernetes_subnet_cidr, 0))
    error_message = "Kubernetes subnet CIDR must be a valid IPv4 CIDR block."
  }
}

############################################
# Backend Services Subnet Configuration
############################################

variable "backend_subnet_name" {
  description = "Name of the backend services subnet"
  type        = string
}

variable "backend_subnet_cidr" {
  description = "CIDR range for backend services subnet"
  type        = string

  validation {
    condition     = can(cidrhost(var.backend_subnet_cidr, 0))
    error_message = "Backend subnet CIDR must be a valid IPv4 CIDR block."
  }
}

############################################
# Private Google Access
############################################

variable "enable_private_google_access" {
  description = "Enable Private Google Access for subnets"
  type        = bool
  default     = true
}

############################################
# VPC Flow Logs Configuration
############################################

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_aggregation_interval" {
  description = "Aggregation interval for flow logs"
  type        = string
  default     = "INTERVAL_5_SEC"

  validation {
    condition = contains([
      "INTERVAL_5_SEC",
      "INTERVAL_30_SEC",
      "INTERVAL_1_MIN",
      "INTERVAL_5_MIN",
      "INTERVAL_10_MIN",
      "INTERVAL_15_MIN"
    ], var.flow_logs_aggregation_interval)
    error_message = "Invalid flow logs aggregation interval."
  }
}

variable "flow_logs_sampling" {
  description = "Sampling rate for flow logs (0.0–1.0)"
  type        = number
  default     = 0.5

  validation {
    condition     = var.flow_logs_sampling >= 0 && var.flow_logs_sampling <= 1
    error_message = "Flow logs sampling must be between 0.0 and 1.0."
  }
}

variable "flow_logs_metadata" {
  description = "Metadata inclusion for flow logs"
  type        = string
  default     = "INCLUDE_ALL_METADATA"

  validation {
    condition     = contains(["EXCLUDE_ALL_METADATA", "INCLUDE_ALL_METADATA", "CUSTOM_METADATA"], var.flow_logs_metadata)
    error_message = "Invalid flow logs metadata option."
  }
}

############################################
# Reserved Internal IPs – Kubernetes
############################################

variable "k8s_master_ip" {
  description = "Reserved internal IP for Kubernetes master node"
  type        = string

  validation {
    condition = (
      can(cidrhost("${var.kubernetes_subnet_cidr}", 0)) &&
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.k8s_master_ip))
    )
    error_message = "k8s_master_ip must be a valid IPv4 address within the Kubernetes subnet CIDR."
  }
}


variable "k8s_worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 4

  validation {
    condition     = var.k8s_worker_count >= 1 && var.k8s_worker_count <= 100
    error_message = "Worker count must be between 1 and 100."
  }
}

variable "k8s_worker_ips" {
  description = "List of reserved internal IPs for Kubernetes worker nodes"
  type        = list(string)

  validation {
    condition     = length(var.k8s_worker_ips) == var.k8s_worker_count
    error_message = "Number of worker IPs must match k8s_worker_count."
  }
}

############################################
# Reserved Internal IPs – Backend Services
############################################

variable "backend_service_ips" {
  description = "Map of backend service names to reserved internal IPs"
  type        = map(string)

  validation {
    condition     = length(var.backend_service_ips) >= 1
    error_message = "At least one backend service IP must be specified."
  }
}

############################################
# Design Notes
############################################
# - Subnet may contain legacy GKE secondary ranges (ignored by Terraform)
# - Self-managed Kubernetes uses ONLY primary CIDR
# - Pod networking handled by CNI (Calico / Flannel / Cilium)
# - Reserved IPs ensure deterministic networking
