############################################
# Core
############################################

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Bucket location"
  type        = string
}

############################################
# Terraform State Bucket
############################################

variable "terraform_state_bucket_name" {
  description = "Terraform state bucket name"
  type        = string
}

variable "terraform_state_bucket_storage_class" {
  type    = string
  default = "STANDARD"
}

variable "terraform_state_versioning_enabled" {
  type    = bool
  default = true
}

variable "terraform_state_version_retention" {
  type    = number
  default = 10
}

############################################
# Backup Bucket
############################################

variable "create_backup_bucket" {
  type    = bool
  default = false
}

variable "backup_bucket_name" {
  type    = string
  default = null
}

variable "backup_storage_class" {
  type    = string
  default = "STANDARD"
}

variable "backup_versioning_enabled" {
  type    = bool
  default = true
}

variable "backup_lifecycle_rules" {
  type = list(object({
    age    = number
    action = string
  }))
  default = []
}

variable "backup_bucket_admins" {
  type    = list(string)
  default = []
}

############################################
# Logging Bucket
############################################

variable "create_logging_bucket" {
  type    = bool
  default = false
}

variable "logging_bucket_name" {
  type    = string
  default = ""
}

variable "logging_bucket_storage_class" {
  type    = string
  default = "STANDARD"
}

variable "logging_retention_days" {
  type    = number
  default = 30
}

variable "log_bucket_suffix" {
  type    = string
  default = "-logs"
}

############################################
# Additional Buckets
############################################

variable "additional_buckets" {
  description = "Additional GCS buckets"
  type = map(object({
    name = string
    
    # Use optional() to stop the "missing attribute" errors
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
# Security & Encryption
############################################

variable "enable_uniform_bucket_level_access" {
  type    = bool
  default = true
}

variable "enable_public_access_prevention" {
  type    = string
  default = "enforced"
}

variable "enable_cmek_encryption" {
  type    = bool
  default = false
}

variable "kms_key_name" {
  type    = string
  default = ""
}

############################################
# Logging & IAM
############################################

variable "enable_bucket_logging" {
  type    = bool
  default = false
}

variable "enable_bucket_iam_bindings" {
  type    = bool
  default = false
}

variable "terraform_state_bucket_readers" {
  type    = list(string)
  default = []
}

variable "terraform_state_bucket_writers" {
  type    = list(string)
  default = []
}

############################################
# Labels
############################################

variable "labels" {
  type    = map(string)
  default = {}
}
