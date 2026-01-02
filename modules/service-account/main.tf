# modules/service-account/main.tf
# This module creates service accounts for VMs and workloads

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Service Account for Kubernetes Master Node
resource "google_service_account" "k8s_master_sa" {
  account_id   = var.k8s_master_sa_name
  project      = var.project_id
  display_name = "Kubernetes Master Node Service Account"
  description  = "Service account for Kubernetes master node with confidential computing"
}

# Service Account for Kubernetes Worker Nodes
resource "google_service_account" "k8s_worker_sa" {
  account_id   = var.k8s_worker_sa_name
  project      = var.project_id
  display_name = "Kubernetes Worker Nodes Service Account"
  description  = "Service account for Kubernetes worker nodes with confidential computing"
}

# Service Account for Backend Services (MySQL, MongoDB, Redis, etc.)
resource "google_service_account" "backend_services_sa" {
  account_id   = var.backend_services_sa_name
  project      = var.project_id
  display_name = "Backend Services Service Account"
  description  = "Service account for backend services VMs"
}

# IAM bindings for Kubernetes Master SA
resource "google_project_iam_member" "k8s_master_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.k8s_master_sa.email}"
}

resource "google_project_iam_member" "k8s_master_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.k8s_master_sa.email}"
}

# IAM bindings for Kubernetes Worker SA
resource "google_project_iam_member" "k8s_worker_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.k8s_worker_sa.email}"
}

resource "google_project_iam_member" "k8s_worker_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.k8s_worker_sa.email}"
}

resource "google_project_iam_member" "k8s_worker_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.k8s_worker_sa.email}"
}

# IAM bindings for Backend Services SA
resource "google_project_iam_member" "backend_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.backend_services_sa.email}"
}

resource "google_project_iam_member" "backend_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.backend_services_sa.email}"
}

# TODO: Add Cloud Storage access if needed
# resource "google_project_iam_member" "backend_storage_object_viewer" {
#   project = var.project_id
#   role    = "roles/storage.objectViewer"
#   member  = "serviceAccount:${google_service_account.backend_services_sa.email}"
# }

# TODO: For KBS Service Account (Key Broker Service)
# This will need access to KMS in Convozen project via Workload Identity Federation
# Will be handled in workload-identity module