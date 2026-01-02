# modules/shared-vpc/main.tf
# VPC Network Module for Callzen (Shared VPC ready, but disabled by default)

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
# VPC Network
############################################

resource "google_compute_network" "shared_vpc" {
  name                    = var.network_name
  project                 = var.host_project_id
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  mtu                     = var.mtu
  description             = var.description

  # Default internet routes are kept
}

############################################
# (OPTIONAL / FUTURE) Enable Shared VPC Host
############################################
# Disabled by default because org-level permission is not available

resource "google_compute_shared_vpc_host_project" "host" {
  count   = var.enable_shared_vpc_host ? 1 : 0
  project = var.host_project_id

  depends_on = [google_compute_network.shared_vpc]
}

############################################
# (OPTIONAL / FUTURE) Attach Service Projects
############################################


resource "google_compute_shared_vpc_service_project" "service" {
  count = (
    var.enable_shared_vpc_host
    ? length(var.service_project_ids)
    : 0
  )

  host_project    = var.host_project_id
  service_project = var.service_project_ids[count.index]

  depends_on = [google_compute_shared_vpc_host_project.host]
}
