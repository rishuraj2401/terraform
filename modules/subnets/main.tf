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
# Data Sources (Fetch Existing Subnets)
############################################

# 1. Fetch Kubernetes Subnet details
data "google_compute_subnetwork" "k8s" {
  name    = var.kubernetes_subnet_name
  region  = var.region
  project = var.host_project_id
}

# 2. Fetch Backend Subnet details (NEW ADDITION)
# Yeh zaroori hai taaki hum backend IPs ko sahi subnet me bana sakein
data "google_compute_subnetwork" "backend" {
  name    = var.backend_subnet_name
  region  = var.region
  project = var.host_project_id
}

############################################
# Reserved Internal IPs – Kubernetes Master
############################################

resource "google_compute_address" "k8s_master_ip" {
  name         = "${var.kubernetes_subnet_name}-master-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"

  subnetwork = data.google_compute_subnetwork.k8s.self_link
  address    = var.k8s_master_ip

  description = "Reserved internal IP for Kubernetes master node"
}

############################################
# Reserved Internal IPs – Kubernetes Workers
############################################

resource "google_compute_address" "k8s_worker_ips" {
  count        = var.k8s_worker_count
  name         = "${var.kubernetes_subnet_name}-worker-${count.index + 1}-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"

  subnetwork = data.google_compute_subnetwork.k8s.self_link
  address    = var.k8s_worker_ips[count.index]

  description = "Reserved internal IP for Kubernetes worker node ${count.index + 1}"
}

############################################
# Reserved Internal IPs – Backend Services
############################################

resource "google_compute_address" "backend_service_ips" {
  for_each     = var.backend_service_ips
  
  # Name updated to use backend subnet name prefix
  name         = "${var.backend_subnet_name}-${each.key}-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"

  # FIX: Pointing to Backend Subnet (instead of K8s subnet)
  subnetwork = data.google_compute_subnetwork.backend.self_link
  address    = each.value

  description = "Reserved internal IP for backend service: ${each.key}"
}