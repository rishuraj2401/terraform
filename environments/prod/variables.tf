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

variable "kubernetes_subnet_cidr" {
  type = string
}

variable "backend_subnet_name" {
  type = string
}

variable "backend_subnet_cidr" {
  type = string
}

############################################
# Reserved Internal IPs
############################################

variable "k8s_master_ip" {
  type = string
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

variable "k8s_master_name" {
  type = string
}

variable "k8s_master_machine_type" {
  type = string
}

variable "k8s_master_boot_disk_size" {
  type = number
}

variable "k8s_master_startup_script" {
  type = string
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
  type = string
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
    name          = string
    location      = string
    storage_class = string
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
