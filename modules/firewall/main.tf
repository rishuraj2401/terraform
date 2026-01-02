# modules/firewall/main.tf
# Firewall rules for Callzen infrastructure (self-managed Kubernetes)

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
# Locals
############################################

locals {
  network_short_name = basename(var.network_self_link)
}

############################################
# Rule 1: Allow internal traffic (TOGGLE)
############################################

resource "google_compute_firewall" "allow_internal" {
  count   = var.enable_internal_traffic ? 1 : 0
  name    = "${local.network_short_name}-allow-internal"
  project = var.project_id
  network = var.network_self_link

  description = "Allow all internal traffic within VPC"
  direction   = "INGRESS"
  priority    = var.default_priority

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  source_ranges = var.internal_source_ranges

  log_config {
    metadata = var.firewall_log_metadata
  }
}

############################################
# Rule 2: Allow Kubernetes API (OPEN)
############################################

resource "google_compute_firewall" "allow_k8s_api" {
  name    = "${local.network_short_name}-allow-k8s-api"
  project = var.project_id
  network = var.network_self_link

  description = "Allow access to Kubernetes API server"
  direction   = "INGRESS"
  priority    = var.default_priority

  allow {
    protocol = "tcp"
    ports    = [tostring(var.k8s_api_port)]
  }

  source_ranges = var.k8s_api_source_ranges
  target_tags   = ["k8s-master"]

  log_config {
    metadata = var.firewall_log_metadata
  }
}

############################################
# Rule 3: Allow SSH via IAP (TOGGLE)
############################################

resource "google_compute_firewall" "allow_iap_ssh" {
  count   = var.enable_iap_ssh ? 1 : 0
  name    = "${local.network_short_name}-allow-iap-ssh"
  project = var.project_id
  network = var.network_self_link

  description = "Allow SSH access via Google IAP"
  direction   = "INGRESS"
  priority    = var.default_priority

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.iap_source_ranges
  target_tags   = ["bastion", "k8s-master", "k8s-worker"]

  log_config {
    metadata = var.firewall_log_metadata
  }
}

############################################
# Rule 4: Allow Load Balancer Health Checks (TOGGLE)
############################################

resource "google_compute_firewall" "allow_health_checks" {
  count   = var.enable_health_checks ? 1 : 0
  name    = "${local.network_short_name}-allow-health-checks"
  project = var.project_id
  network = var.network_self_link

  description = "Allow health checks from Google Cloud Load Balancers"
  direction   = "INGRESS"
  priority    = var.default_priority

  allow {
    protocol = "tcp"
    ports    = var.health_check_ports
  }

  source_ranges = var.health_check_source_ranges
  target_tags   = ["backend"]

  dynamic "log_config" {
    for_each = var.enable_firewall_logs ? [1] : []
    content {
      metadata = var.firewall_log_metadata
    }
  }

}

############################################
# Notes
############################################
# - Default GCP behavior denies all other ingress
# - No explicit egress rules (GCP allows all egress by default)
# - Tags align with compute module:
#   k8s-master, k8s-worker, backend, bastion
