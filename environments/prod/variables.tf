############################################
# Core Project & Location
############################################

variable "host_project_id" {
  description = "GCP project ID (Shared VPC host / client project)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

############################################
# VPC / Shared VPC
############################################

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "routing_mode" {
  description = "VPC routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "REGIONAL"
}

variable "enable_shared_vpc_host" {
  description = "Enable this project as Shared VPC host"
  type        = bool
  default     = false
}

variable "service_project_ids" {
  description = "Service projects attached to Shared VPC"
  type        = list(string)
  default     = []
}

############################################
# Subnets
############################################

variable "kubernetes_subnet_name" {
  type = string
}



variable "backend_subnet_name" {
  type = string
}


variable "service_project_id" {
  description = "The ID of the service project where resources are created"
  type        = string
}

############################################
# Reserved Internal IPs
############################################

variable "k8s_master_count" {
  description = "Number of Kubernetes master nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.k8s_master_count >= 1 && var.k8s_master_count <= 9
    error_message = "k8s_master_count must be between 1 and 9."
  }
}

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
  description = "Reserved internal IP for Kubernetes master (legacy single-master input)"
  type        = string
  default     = null

  validation {
    condition     = var.k8s_master_ip == null || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.k8s_master_ip))
    error_message = "k8s_master_ip must be null or a valid IPv4 address."
  }
}

variable "k8s_worker_count" {
  type = number
}

variable "k8s_worker_ips" {
  type = list(string)
}

variable "backend_service_ips" {
  description = "Static IPs for backend services (mysql, mongo, redis, kbs, etc.)"
  type        = map(string)
}

############################################
# Firewall
############################################

variable "internal_source_ranges" {
  description = "CIDR ranges allowed for internal communication"
  type        = list(string)
}

variable "k8s_api_source_ranges" {
  description = "CIDR ranges allowed to access Kubernetes API (6443)"
  type        = list(string)
}

############################################
# Service Accounts
############################################

variable "k8s_master_sa_name" {
  type = string
}

variable "k8s_worker_sa_name" {
  type = string
}

variable "backend_services_sa_name" {
  type = string
}

############################################
# Kubernetes – Compute
############################################

variable "k8s_master_name_prefix" {
  description = "Name prefix/base for Kubernetes master nodes (e.g. k8s-master)"
  type        = string
  default     = "k8s-master"
}

# Legacy (single master): kept for backward compatibility
variable "k8s_master_name" {
  description = "Name of the Kubernetes master node (legacy single-master input)"
  type        = string
  default     = null
}

variable "k8s_master_machine_type" {
  type = string
}

variable "k8s_master_boot_disk_size" {
  type = number
}

variable "k8s_master_startup_script" {
  type    = string
  default = ""
}

variable "k8s_worker_name_prefix" {
  type = string
}

variable "k8s_worker_machine_type" {
  type = string
}

variable "k8s_worker_boot_disk_size" {
  type = number
}

variable "k8s_worker_startup_script" {
  type    = string
  default = ""
}

############################################
# Backend Services – Compute
############################################

variable "backend_services" {
  description = "Backend services VM definitions"
  type = map(object({
    name                          = string
    machine_type                  = string
    boot_disk_size                = number
    data_disk_size                = number
    ip_address                    = string
    enable_confidential_computing = bool
    startup_script                = optional(string)
  }))
}

############################################
# Golden Images (MANUAL lifecycle)
############################################

variable "os_images" {
  description = "Golden images created manually from GCS tar.gz and registered in GCP (per role & per backend service)"
  type = object({
    k8s_master = string
    k8s_worker = string
    backend    = map(string)
  })
}

############################################
# Disks
############################################

variable "boot_disk_type" {
  type = string
}

############################################
# Cloud Storage
############################################

variable "terraform_state_bucket_name" {
  type = string
}

variable "create_backup_bucket" {
  type    = bool
  default = false
}

variable "backup_bucket_name" {
  type    = string
  default = null
}

variable "additional_buckets" {
  description = "Additional GCS buckets to create"
  type = map(object({
    name               = string
    storage_class      = optional(string, "STANDARD")
    versioning_enabled = optional(bool, true)
    lifecycle_rules = optional(list(object({
      age    = number
      action = string
    })), [])
    labels = optional(map(string), {})
  }))
  default = {}
}

############################################
# Artifact Registry
############################################

variable "docker_repository_id" {
  type = string
}

############################################
# Common Labels
############################################

variable "labels" {
  type    = map(string)
  default = {}
}
