############################################
# Variables for Compute Instance Module
# (Confidential VMs + Golden Images)
############################################

############################################
# Core
############################################

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "zone" {
  description = "The GCP zone for compute instances (e.g. asia-south1-a)"
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.zone))
    error_message = "Zone must be a valid GCP zone (e.g., asia-south1-a)."
  }
}

variable "network_self_link" {
  description = "Self-link of the VPC network"
  type        = string
}

variable "kubernetes_subnet_self_link" {
  description = "Self-link of the Kubernetes subnet"
  type        = string
}

variable "backend_subnet_self_link" {
  description = "Self-link of the backend services subnet"
  type        = string
}

############################################
# OS Images (Golden Images – REQUIRED)
############################################

variable "os_images" {
  description = <<EOT
Golden images to use for VMs.

Images are:
- Uploaded to GCS as tar.gz
- Registered manually using `gcloud compute images create`
- REFERENCED only by Terraform (no lifecycle mgmt here)

Structure:
{
  k8s_master = "projects/.../global/images/..."
  k8s_worker = "projects/.../global/images/..."
  backend = {
    mysql = "projects/.../global/images/..."
    mongo = "projects/.../global/images/..."
    redis = "projects/.../global/images/..."
    kbs   = "projects/.../global/images/..."
    llm   = "projects/.../global/images/..."
  }
}
EOT

  type = object({
    k8s_master = string
    k8s_worker = string
    backend    = map(string)
  })

  validation {
    condition     = length(var.os_images.backend) > 0
    error_message = "At least one backend service image must be provided in os_images.backend."
  }
}

############################################
# Disk Configuration
############################################

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-balanced"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme"], var.boot_disk_type)
    error_message = "Invalid boot disk type."
  }
}

variable "data_disk_type" {
  description = "Data disk type"
  type        = string
  default     = "pd-ssd"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme"], var.data_disk_type)
    error_message = "Invalid data disk type."
  }
}

############################################
# Kubernetes Master
############################################

variable "k8s_master_count" {
  description = "Number of Kubernetes master nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.k8s_master_count >= 1 && var.k8s_master_count <= 9
    error_message = "k8s_master_count must be between 1 and 9."
  }
}

variable "k8s_master_name_prefix" {
  description = "Name prefix/base for Kubernetes master nodes (e.g. k8s-master)"
  type        = string
  default     = null
}

# Legacy single-master name (kept for backward compatibility)
variable "k8s_master_name" {
  description = "Name of the Kubernetes master node (legacy single-master input)"
  type        = string
  default     = null
}

variable "k8s_master_machine_type" {
  description = "Machine type for Kubernetes master"
  type        = string
}

variable "k8s_master_boot_disk_size" {
  description = "Boot disk size for Kubernetes master (GB)"
  type        = number

  validation {
    condition     = var.k8s_master_boot_disk_size >= 20
    error_message = "Kubernetes master boot disk size must be at least 20GB."
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
}

variable "k8s_master_sa_email" {
  description = "Service account email for Kubernetes master"
  type        = string
}

variable "k8s_master_startup_script" {
  description = "Startup script for Kubernetes master"
  type        = string
  default     = ""
}

############################################
# Kubernetes Workers
############################################

variable "k8s_worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number

  validation {
    condition     = var.k8s_worker_count >= 1
    error_message = "k8s_worker_count must be at least 1."
  }
}

variable "k8s_worker_name_prefix" {
  description = "Name prefix for Kubernetes workers"
  type        = string
}

variable "k8s_worker_machine_type" {
  description = "Machine type for Kubernetes workers"
  type        = string
}

variable "k8s_worker_boot_disk_size" {
  description = "Boot disk size for Kubernetes workers (GB)"
  type        = number

  validation {
    condition     = var.k8s_worker_boot_disk_size >= 20
    error_message = "Kubernetes worker boot disk size must be at least 20GB."
  }
}

variable "k8s_worker_data_disk_size" {
  description = "Data disk size for Kubernetes workers (GB, 0 disables)"
  type        = number
  default     = 0
}

variable "k8s_worker_ips" {
  description = "List of reserved internal IPs for Kubernetes workers"
  type        = list(string)

  validation {
    condition     = length(var.k8s_worker_ips) == var.k8s_worker_count
    error_message = "k8s_worker_ips length must match k8s_worker_count."
  }
}

variable "k8s_worker_sa_email" {
  description = "Service account email for Kubernetes workers"
  type        = string
}

variable "k8s_worker_startup_script" {
  description = "Startup script for Kubernetes workers"
  type        = string
  default     = ""
}

############################################
# Backend Services
############################################

variable "backend_services" {
  description = "Backend services configuration"
  type = map(object({
    name                          = string
    machine_type                  = string
    boot_disk_size                = number
    data_disk_size                = number
    ip_address                    = string
    enable_confidential_computing = bool
    startup_script                = optional(string, "")
  }))

  validation {
    condition     = length(var.backend_services) > 0
    error_message = "At least one backend service must be defined."
  }
}

variable "backend_services_sa_email" {
  description = "Service account email for backend services"
  type        = string
}

############################################
# VM Behavior & Security
############################################

variable "enable_secure_boot" {
  description = "Enable Secure Boot"
  type        = bool
  default     = true
}

variable "enable_vtpm" {
  description = "Enable vTPM"
  type        = bool
  default     = true
}

variable "enable_integrity_monitoring" {
  description = "Enable integrity monitoring"
  type        = bool
  default     = true
}

variable "automatic_restart" {
  description = "Automatically restart VMs"
  type        = bool
  default     = true
}

variable "on_host_maintenance" {
  description = "Host maintenance behavior (TERMINATE required for confidential VMs)"
  type        = string
  default     = "TERMINATE"

  validation {
    condition     = var.on_host_maintenance == "TERMINATE"
    error_message = "Confidential VMs must use TERMINATE."
  }
}

variable "preemptible" {
  description = "Use preemptible instances"
  type        = bool
  default     = false
}

############################################
# Metadata / SSH
############################################

variable "enable_oslogin" {
  description = "Enable OS Login"
  type        = bool
  default     = true
}

variable "block_project_ssh_keys" {
  description = "Block project-wide SSH keys"
  type        = bool
  default     = true
}

variable "custom_metadata" {
  description = "Additional metadata for VMs"
  type        = map(string)
  default     = {}
}

############################################
# Labels
############################################

variable "labels" {
  description = "Labels applied to compute resources"
  type        = map(string)
  default     = {}
}

############################################
# Future (kept but NOT wired yet)
############################################

variable "enable_gpu" {
  description = "Enable GPU (future use)"
  type        = bool
  default     = false
}

variable "enable_cmek_encryption" {
  description = "Enable CMEK encryption (future use)"
  type        = bool
  default     = false
}

variable "kms_key_self_link" {
  description = "KMS key self-link (future use)"
  type        = string
  default     = ""
}
