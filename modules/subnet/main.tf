# modules/subnet/main.tf
# Subnet module (Self-managed Kubernetes, existing subnet reuse-safe)

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
# Kubernetes Subnet (Primary range only)
############################################

resource "google_compute_subnetwork" "kubernetes_subnet" {
  name    = var.kubernetes_subnet_name
  project = var.project_id
  region  = var.region

  # Reuse existing VPC
  network = var.network_self_link

  # PRIMARY CIDR ONLY (self-managed K8s)
  ip_cidr_range = var.kubernetes_subnet_cidr

  description = "Self-managed Kubernetes subnet (primary CIDR only)"

  private_ip_google_access = var.enable_private_google_access

  # Flow logs (enabled/disabled via flag)
  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.flow_logs_aggregation_interval
      flow_sampling        = var.flow_logs_sampling
      metadata             = var.flow_logs_metadata
    }
  }

  ############################################
  # IMPORTANT:
  # This subnet previously had GKE secondary ranges.
  # We intentionally DO NOT manage them.
  ############################################
  lifecycle {
    ignore_changes = [
      secondary_ip_range
    ]
  }
}

############################################
# Backend Services Subnet
############################################

resource "google_compute_subnetwork" "backend_subnet" {
  name    = var.backend_subnet_name
  project = var.project_id
  region  = var.region

  network       = var.network_self_link
  ip_cidr_range = var.backend_subnet_cidr

  description = "Backend services subnet (databases, internal services)"

  private_ip_google_access = var.enable_private_google_access

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.flow_logs_aggregation_interval
      flow_sampling        = var.flow_logs_sampling
      metadata             = var.flow_logs_metadata
    }
  }
}

############################################
# Reserved Internal IPs - Kubernetes
############################################

resource "google_compute_address" "k8s_master_ip" {
  name         = "${var.kubernetes_subnet_name}-master-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"

  subnetwork = google_compute_subnetwork.kubernetes_subnet.id
  address    = var.k8s_master_ip

  description = "Reserved internal IP for Kubernetes master node"
}

resource "google_compute_address" "k8s_worker_ips" {
  count        = var.k8s_worker_count
  name         = "${var.kubernetes_subnet_name}-worker-${count.index + 1}-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"

  subnetwork = google_compute_subnetwork.kubernetes_subnet.id
  address    = var.k8s_worker_ips[count.index]

  description = "Reserved internal IP for Kubernetes worker node ${count.index + 1}"
}

############################################
# Reserved Internal IPs - Backend Services
############################################

resource "google_compute_address" "backend_service_ips" {
  for_each     = var.backend_service_ips
  name         = "${var.backend_subnet_name}-${each.key}-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"

  subnetwork = google_compute_subnetwork.backend_subnet.id
  address    = each.value

  description = "Reserved internal IP for ${each.key} service"
}
