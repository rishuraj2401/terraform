# modules/artifact-registry/main.tf
# This module creates Artifact Registry repositories for encrypted container images

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Docker Repository for Confidential Container Images
resource "google_artifact_registry_repository" "docker_repo" {
  repository_id = var.docker_repository_id
  project       = var.project_id
  location      = var.location
  format        = "DOCKER"

  description = var.docker_repository_description

  # TODO: Add customer-managed encryption key from KMS for image encryption
  # kms_key_name = var.kms_key_self_link

  labels = var.labels
}

# Additional repositories (Maven, npm, Python, etc.)
resource "google_artifact_registry_repository" "additional_repos" {
  for_each = var.additional_repositories

  repository_id = each.value.repository_id
  project       = var.project_id
  location      = var.location
  format        = each.value.format

  description = lookup(each.value, "description", "")

  labels = merge(var.labels, lookup(each.value, "labels", {}))
}

# IAM binding to allow workers to pull images
resource "google_artifact_registry_repository_iam_member" "k8s_worker_reader" {
  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.k8s_worker_sa_email}"
}

# TODO: Add IAM bindings for CI/CD service accounts to push images
# resource "google_artifact_registry_repository_iam_member" "cicd_writer" {
#   project    = var.project_id
#   location   = var.location
#   repository = google_artifact_registry_repository.docker_repo.name
#   role       = "roles/artifactregistry.writer"
#   member     = "serviceAccount:${var.cicd_sa_email}"
# }