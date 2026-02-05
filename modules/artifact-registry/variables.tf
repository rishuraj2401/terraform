# modules/artifact-registry/variables.tf
# Variables for Artifact Registry Module

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "Location for Artifact Registry (region or multi-region)"
  type        = string
  default     = "asia-south1"

  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}

# ==========================================
# Docker Repository Configuration
# ==========================================

variable "docker_repository_id" {
  description = "ID of the Docker repository (must be 2-63 characters, lowercase, alphanumeric, and hyphens)"
  type        = string
  default     = "callzen-docker-repo"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{0,61}[a-z0-9]$", var.docker_repository_id))
    error_message = "Repository ID must be 2-63 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens."
  }
}

variable "docker_repository_description" {
  description = "Description of the Docker repository"
  type        = string
  default     = "Docker repository for confidential container images"
}

variable "docker_repository_mode" {
  description = "Repository mode (STANDARD_REPOSITORY or VIRTUAL_REPOSITORY)"
  type        = string
  default     = "STANDARD_REPOSITORY"

  validation {
    condition     = contains(["STANDARD_REPOSITORY", "VIRTUAL_REPOSITORY"], var.docker_repository_mode)
    error_message = "Repository mode must be STANDARD_REPOSITORY or VIRTUAL_REPOSITORY."
  }
}

# ==========================================
# Image Scanning Configuration
# ==========================================

variable "enable_vulnerability_scanning" {
  description = "Enable automatic vulnerability scanning for container images"
  type        = bool
  default     = true
}

variable "vulnerability_scanning_mode" {
  description = "Vulnerability scanning mode (CONTINUOUS_ANALYSIS or ON_PUSH)"
  type        = string
  default     = "CONTINUOUS_ANALYSIS"

  validation {
    condition     = contains(["CONTINUOUS_ANALYSIS", "ON_PUSH"], var.vulnerability_scanning_mode)
    error_message = "Scanning mode must be CONTINUOUS_ANALYSIS or ON_PUSH."
  }
}

# ==========================================
# Cleanup Policies for Old Images
# ==========================================

variable "enable_cleanup_policies" {
  description = "Enable cleanup policies for old images"
  type        = bool
  default     = true
}

variable "cleanup_policy_keep_tag_patterns" {
  description = "Tag patterns to keep (e.g., ['latest', 'stable-*', 'v[0-9]*'])"
  type        = list(string)
  default     = ["latest", "stable-*", "v[0-9]*", "prod-*"]
}

variable "cleanup_policy_keep_count" {
  description = "Number of most recent versions to keep for each tag pattern (0 for unlimited)"
  type        = number
  default     = 10

  validation {
    condition     = var.cleanup_policy_keep_count >= 0
    error_message = "Keep count must be 0 or greater."
  }
}

variable "cleanup_policy_age_days" {
  description = "Delete images older than this many days (0 to disable age-based cleanup)"
  type        = number
  default     = 90

  validation {
    condition     = var.cleanup_policy_age_days >= 0
    error_message = "Age days must be 0 or greater."
  }
}

variable "cleanup_policy_untagged" {
  description = "Delete untagged images"
  type        = bool
  default     = true
}

# ==========================================
# IAM Configuration
# ==========================================

variable "k8s_worker_sa_email" {
  description = "Service account email for Kubernetes workers (to pull images)"
  type        = string
}

variable "additional_readers" {
  description = "Additional service accounts or users who can read images"
  type        = list(string)
  default     = []

  # Example: ["serviceAccount:cicd@project.iam.gserviceaccount.com"]
}

variable "additional_writers" {
  description = "Additional service accounts or users who can push images"
  type        = list(string)
  default     = []

  # Example: ["serviceAccount:gocd@project.iam.gserviceaccount.com"]
}

variable "additional_admins" {
  description = "Additional service accounts or users who can administer repository"
  type        = list(string)
  default     = []
}

# ==========================================
# Encryption Configuration
# ==========================================

variable "enable_cmek_encryption" {
  description = "Enable Customer-Managed Encryption Keys (CMEK) for image encryption"
  type        = bool
  default     = false # Will be enabled after KMS module is created
}

variable "kms_key_name" {
  description = "KMS key name for image encryption (if CMEK is enabled)"
  type        = string
  default     = ""
}

# ==========================================
# Additional Repositories
# ==========================================

variable "additional_repositories" {
  description = "Additional repositories to create (Maven, npm, Python, etc.)"
  type = map(object({
    repository_id = string
    format        = string
    description   = optional(string, "")
    mode          = optional(string, "STANDARD_REPOSITORY")
    labels        = optional(map(string), {})
  }))
  default = {} # No additional repositories needed currently

  # Example usage:
  # additional_repositories = {
  #   maven = {
  #     repository_id = "callzen-maven-repo"
  #     format        = "MAVEN"
  #     description   = "Maven repository for Java artifacts"
  #   }
  #   npm = {
  #     repository_id = "callzen-npm-repo"
  #     format        = "NPM"
  #     description   = "npm repository for Node.js packages"
  #   }
  #   python = {
  #     repository_id = "callzen-python-repo"
  #     format        = "PYTHON"
  #     description   = "Python repository for pip packages"
  #   }
  # }
}

# ==========================================
# Remote Repository Configuration
# ==========================================

variable "enable_remote_repositories" {
  description = "Enable remote repositories (proxy for Docker Hub, etc.)"
  type        = bool
  default     = false
}

variable "remote_repositories" {
  description = "Remote repository configurations"
  type = map(object({
    repository_id = string
    description   = optional(string, "")
    upstream_url  = string
    username      = optional(string, "")
    password      = optional(string, "")
  }))
  default = {}

  # Example:
  # remote_repositories = {
  #   dockerhub = {
  #     repository_id = "dockerhub-proxy"
  #     description   = "Proxy for Docker Hub"
  #     upstream_url  = "https://registry-1.docker.io"
  #   }
  # }
}

# ==========================================
# Resource Labels
# ==========================================

variable "labels" {
  description = "Labels to apply to all Artifact Registry repositories"
  type        = map(string)
  default = {
    environment = "production"
    project     = "callzen"
    managed-by  = "terraform"
  }
}

# ==========================================
# Naming Convention
# ==========================================

variable "repository_name_prefix" {
  description = "Prefix for repository names"
  type        = string
  default     = ""
}

variable "repository_name_suffix" {
  description = "Suffix for repository names"
  type        = string
  default     = ""
}

# ==========================================
# Immutability Configuration
# ==========================================

variable "enable_immutable_tags" {
  description = "Prevent tag overwrites (recommended for production)"
  type        = bool
  default     = false # Can enable later for stricter control
}

# ==========================================
# Notifications Configuration
# ==========================================

variable "enable_notifications" {
  description = "Enable Pub/Sub notifications for repository events"
  type        = bool
  default     = false
}

variable "notification_topic" {
  description = "Pub/Sub topic for repository notifications"
  type        = string
  default     = ""
}

# Note: Single Docker repository sufficient for current needs
# Note: Vulnerability scanning enabled for security
# Note: Cleanup policies configured to retain important tags and delete old images
# Note: No Maven/npm/Python repositories needed currently
# Note: CMEK encryption will be added after KMS module creation