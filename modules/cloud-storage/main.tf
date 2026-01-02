# modules/cloud-storage/main.tf
# This module creates Cloud Storage buckets

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

############################################
# Terraform State Bucket
############################################

resource "google_storage_bucket" "terraform_state" {
  name     = var.terraform_state_bucket_name
  project  = var.project_id
  location = var.location

  storage_class = var.terraform_state_bucket_storage_class

  versioning {
    enabled = var.terraform_state_versioning_enabled
  }

  # ✅ FIXED: boolean, not block
  uniform_bucket_level_access = true

  public_access_prevention = var.enable_public_access_prevention

  lifecycle_rule {
    condition {
      num_newer_versions = var.terraform_state_version_retention
    }
    action {
      type = "Delete"
    }
  }

  dynamic "encryption" {
    for_each = var.enable_cmek_encryption && var.kms_key_name != "" ? [1] : []
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  dynamic "logging" {
    for_each = var.enable_bucket_logging && var.create_logging_bucket ? [1] : []
    content {
      log_bucket = google_storage_bucket.logging[0].name
    }
  }

  labels = var.labels
}

############################################
# Backup Bucket
############################################

resource "google_storage_bucket" "backups" {
  count    = var.create_backup_bucket ? 1 : 0
  name     = var.backup_bucket_name
  project  = var.project_id
  location = var.location

  storage_class = var.backup_storage_class

  versioning {
    enabled = var.backup_versioning_enabled
  }

  # ✅ FIXED
  uniform_bucket_level_access = var.enable_uniform_bucket_level_access

  public_access_prevention = var.enable_public_access_prevention

  dynamic "lifecycle_rule" {
    for_each = var.backup_lifecycle_rules
    content {
      condition {
        age = lifecycle_rule.value.age
      }
      action {
        type = lifecycle_rule.value.action
      }
    }
  }

  dynamic "encryption" {
    for_each = var.enable_cmek_encryption && var.kms_key_name != "" ? [1] : []
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  dynamic "logging" {
    for_each = var.enable_bucket_logging && var.create_logging_bucket ? [1] : []
    content {
      log_bucket = google_storage_bucket.logging[0].name
    }
  }

  labels = var.labels

  depends_on = [google_storage_bucket.logging]
}

############################################
# Logging Bucket
############################################

resource "google_storage_bucket" "logging" {
  count    = var.create_logging_bucket ? 1 : 0
  name     = var.logging_bucket_name != "" ? var.logging_bucket_name : "${var.terraform_state_bucket_name}${var.log_bucket_suffix}"
  project  = var.project_id
  location = var.location

  storage_class = var.logging_bucket_storage_class

  # ✅ FIXED
  uniform_bucket_level_access = var.enable_uniform_bucket_level_access

  public_access_prevention = var.enable_public_access_prevention

  dynamic "lifecycle_rule" {
    for_each = var.logging_retention_days > 0 ? [1] : []
    content {
      condition {
        age = var.logging_retention_days
      }
      action {
        type = "Delete"
      }
    }
  }

  labels = merge(var.labels, {
    purpose = "access-logs"
  })
}

############################################
# Additional Buckets
############################################

resource "google_storage_bucket" "additional" {
  for_each = var.additional_buckets

  name     = each.value.name
  project  = var.project_id
  location = var.location

  storage_class = each.value.storage_class

  versioning {
    enabled = each.value.versioning_enabled
  }

  # ✅ FIXED
  uniform_bucket_level_access = var.enable_uniform_bucket_level_access

  public_access_prevention = var.enable_public_access_prevention

  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules
    content {
      condition {
        age = lifecycle_rule.value.age
      }
      action {
        type = lifecycle_rule.value.action
      }
    }
  }

  dynamic "encryption" {
    for_each = var.enable_cmek_encryption && var.kms_key_name != "" ? [1] : []
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  dynamic "logging" {
    for_each = var.enable_bucket_logging && var.create_logging_bucket ? [1] : []
    content {
      log_bucket = google_storage_bucket.logging[0].name
    }
  }

  labels = merge(var.labels, each.value.labels)

  depends_on = [google_storage_bucket.logging]
}

############################################
# IAM Bindings
############################################

resource "google_storage_bucket_iam_member" "state_bucket_readers" {
  count  = var.enable_bucket_iam_bindings ? length(var.terraform_state_bucket_readers) : 0
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectViewer"
  member = var.terraform_state_bucket_readers[count.index]
}

resource "google_storage_bucket_iam_member" "state_bucket_writers" {
  count  = var.enable_bucket_iam_bindings ? length(var.terraform_state_bucket_writers) : 0
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"
  member = var.terraform_state_bucket_writers[count.index]
}

resource "google_storage_bucket_iam_member" "backup_bucket_admins" {
  count  = var.enable_bucket_iam_bindings && var.create_backup_bucket ? length(var.backup_bucket_admins) : 0
  bucket = google_storage_bucket.backups[0].name
  role   = "roles/storage.admin"
  member = var.backup_bucket_admins[count.index]
}
