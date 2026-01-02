# modules/service-account/variables.tf
# Variables for Service Account Module

variable "project_id" {
  description = "The GCP project ID where service accounts will be created"
  type        = string
}

# ==========================================
# Kubernetes Master Service Account
# ==========================================

variable "k8s_master_sa_name" {
  description = "Service account ID for Kubernetes master node (must be 6-30 characters, lowercase letters, digits, hyphens)"
  type        = string
  default     = "k8s-master-sa"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{4,28}[a-z0-9]$", var.k8s_master_sa_name))
    error_message = "Service account name must be 6-30 characters, start with lowercase letter, contain only lowercase letters, digits, and hyphens."
  }
}

variable "k8s_master_sa_display_name" {
  description = "Display name for Kubernetes master service account"
  type        = string
  default     = "Kubernetes Master Node Service Account"
}

variable "k8s_master_sa_description" {
  description = "Description for Kubernetes master service account"
  type        = string
  default     = "Service account for Kubernetes master node with confidential computing"
}

# ==========================================
# Kubernetes Worker Service Account
# ==========================================

variable "k8s_worker_sa_name" {
  description = "Service account ID for Kubernetes worker nodes"
  type        = string
  default     = "k8s-worker-sa"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{4,28}[a-z0-9]$", var.k8s_worker_sa_name))
    error_message = "Service account name must be 6-30 characters, start with lowercase letter, contain only lowercase letters, digits, and hyphens."
  }
}

variable "k8s_worker_sa_display_name" {
  description = "Display name for Kubernetes worker service account"
  type        = string
  default     = "Kubernetes Worker Nodes Service Account"
}

variable "k8s_worker_sa_description" {
  description = "Description for Kubernetes worker service account"
  type        = string
  default     = "Service account for Kubernetes worker nodes with confidential computing and Kata Containers"
}

# ==========================================
# Backend Services Service Account
# ==========================================

variable "backend_services_sa_name" {
  description = "Service account ID for backend services (MySQL, MongoDB, Redis, etc.)"
  type        = string
  default     = "backend-services-sa"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{4,28}[a-z0-9]$", var.backend_services_sa_name))
    error_message = "Service account name must be 6-30 characters, start with lowercase letter, contain only lowercase letters, digits, and hyphens."
  }
}

variable "backend_services_sa_display_name" {
  description = "Display name for backend services service account"
  type        = string
  default     = "Backend Services Service Account"
}

variable "backend_services_sa_description" {
  description = "Description for backend services service account"
  type        = string
  default     = "Service account for backend services VMs (MySQL, MongoDB, Redis, KBS, etc.)"
}

# ==========================================
# IAM Roles Configuration
# ==========================================

variable "k8s_master_roles" {
  description = "List of IAM roles to grant to Kubernetes master service account"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ]
}

variable "k8s_worker_roles" {
  description = "List of IAM roles to grant to Kubernetes worker service account"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader"
  ]
}

variable "backend_services_roles" {
  description = "List of IAM roles to grant to backend services service account"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ]
}

# ==========================================
# Cross-Project IAM Bindings (for Shared VPC)
# ==========================================

variable "enable_shared_vpc_bindings" {
  description = "Enable cross-project IAM bindings for Shared VPC service project usage"
  type        = bool
  default     = true
}

variable "host_project_id" {
  description = "Host project ID for Shared VPC (if different from project_id)"
  type        = string
  default     = ""
}

variable "service_project_ids" {
  description = "List of service project IDs that need compute.networkUser role on subnets"
  type        = list(string)
  default     = []
  
  # Example: ["callzen-gcp"] for KMS project
  # Note: Service accounts in service projects need networkUser role on host project subnets
}

# ==========================================
# Additional Service Accounts (Future)
# ==========================================

variable "additional_service_accounts" {
  description = "Additional service accounts to create (e.g., CI/CD, monitoring, backup)"
  type = map(object({
    account_id   = string
    display_name = optional(string, "")
    description  = optional(string, "")
    roles        = optional(list(string), [])
  }))
  default = {}

  # Example usage:
  # additional_service_accounts = {
  #   cicd = {
  #     account_id   = "gocd-sa"
  #     display_name = "GoCD CI/CD Service Account"
  #     description  = "Service account for GoCD pipelines"
  #     roles = [
  #       "roles/artifactregistry.writer",
  #       "roles/storage.objectAdmin"
  #     ]
  #   }
  # }
}

# ==========================================
# Service Account Keys (Not Recommended)
# ==========================================

variable "create_service_account_keys" {
  description = "Create service account keys (NOT RECOMMENDED - use Workload Identity or metadata service instead)"
  type        = bool
  default     = false
}

# Note: Predefined roles are sufficient for current setup
# Note: Custom roles not needed at this stage
# Note: Cross-project bindings will be set up for WIF access to KMS in Convozen project