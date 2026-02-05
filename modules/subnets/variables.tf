############################################
# Core Project / Network
############################################

variable "project_id" {
  description = "The Project ID where resources (IPs) will be created"
  type        = string
}

variable "host_project_id" {
  description = "The Host Project ID where Subnets exist"
  type        = string
}
# REMOVED: variable "service_project_id" 
# Reason: Module ke andar hum 'project_id' hi use karenge. 
# Root main.tf se value pass karte waqt hum assign karenge: project_id = var.service_project_id

variable "region" {
  description = "GCP region"
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "Region must be a valid GCP region (e.g., asia-south1)."
  }
}

############################################
# Kubernetes Subnet & IPs
############################################

variable "kubernetes_subnet_name" {
  description = "Name of the existing Kubernetes subnet in Shared VPC"
  type        = string
}

variable "k8s_master_count" {
  description = "Number of Kubernetes master nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.k8s_master_count >= 1 && var.k8s_master_count <= 9
    error_message = "k8s_master_count must be between 1 and 9."
  }
}

# Preferred (HA): provide one IP per master
variable "k8s_master_ips" {
  description = "Reserved internal IPs for Kubernetes master nodes (preferred)"
  type        = list(string)
  default     = null

  validation {
    condition = (
      var.k8s_master_ips == null ||
      (
        length(var.k8s_master_ips) == var.k8s_master_count &&
        alltrue([for ip in var.k8s_master_ips : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))])
      )
    )
    error_message = "k8s_master_ips must be null or a list of valid IPv4 addresses with length equal to k8s_master_count."
  }
}

# Legacy (single master): kept for backward compatibility
variable "k8s_master_ip" {
  description = "Reserved internal IP for Kubernetes master node (legacy single-master input)"
  type        = string
  default     = null

  validation {
    condition     = var.k8s_master_ip == null || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.k8s_master_ip))
    error_message = "k8s_master_ip must be null or a valid IPv4 address."
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
  description = "Reserved internal IPs for Kubernetes worker nodes"
  type        = list(string)
}

############################################
# Backend Subnet & IPs
############################################

variable "backend_subnet_name" {
  description = "Name of the existing Backend subnet"
  type        = string
}

variable "backend_service_ips" {
  description = "Map of backend service names to reserved internal IPs"
  type        = map(string)

  validation {
    condition     = length(var.backend_service_ips) >= 1
    error_message = "At least one backend service IP must be specified."
  }
}