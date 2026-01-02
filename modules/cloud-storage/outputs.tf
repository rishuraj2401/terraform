# modules/cloud-storage/outputs.tf

# Terraform State Bucket Outputs
output "terraform_state_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = google_storage_bucket.terraform_state.name
}

output "terraform_state_bucket_url" {
  description = "URL of the Terraform state bucket"
  value       = google_storage_bucket.terraform_state.url
}

output "terraform_state_bucket_self_link" {
  description = "Self-link of the Terraform state bucket"
  value       = google_storage_bucket.terraform_state.self_link
}

# Backup Bucket Outputs
output "backup_bucket_name" {
  description = "Name of the backup bucket"
  value       = var.create_backup_bucket ? google_storage_bucket.backups[0].name : null
}

output "backup_bucket_url" {
  description = "URL of the backup bucket"
  value       = var.create_backup_bucket ? google_storage_bucket.backups[0].url : null
}

output "backup_bucket_self_link" {
  description = "Self-link of the backup bucket"
  value       = var.create_backup_bucket ? google_storage_bucket.backups[0].self_link : null
}

# Logging Bucket Outputs
output "logging_bucket_name" {
  description = "Name of the logging bucket"
  value       = var.create_logging_bucket ? google_storage_bucket.logging[0].name : null
}

output "logging_bucket_url" {
  description = "URL of the logging bucket"
  value       = var.create_logging_bucket ? google_storage_bucket.logging[0].url : null
}

output "logging_bucket_self_link" {
  description = "Self-link of the logging bucket"
  value       = var.create_logging_bucket ? google_storage_bucket.logging[0].self_link : null
}

# Additional Buckets Outputs
output "additional_bucket_names" {
  description = "Names of additional buckets"
  value       = { for k, v in google_storage_bucket.additional : k => v.name }
}

output "additional_bucket_urls" {
  description = "URLs of additional buckets"
  value       = { for k, v in google_storage_bucket.additional : k => v.url }
}

output "additional_bucket_self_links" {
  description = "Self-links of additional buckets"
  value       = { for k, v in google_storage_bucket.additional : k => v.self_link }
}

# All Buckets Summary
output "all_bucket_names" {
  description = "List of all bucket names created"
  value = concat(
    [google_storage_bucket.terraform_state.name],
    var.create_backup_bucket ? [google_storage_bucket.backups[0].name] : [],
    var.create_logging_bucket ? [google_storage_bucket.logging[0].name] : [],
    [for k, v in google_storage_bucket.additional : v.name]
  )
}