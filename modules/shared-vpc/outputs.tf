# modules/shared-vpc/outputs.tf
# Outputs for VPC / Shared VPC module

output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.shared_vpc.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.shared_vpc.name
}

output "network_self_link" {
  description = "Self-link of the VPC network"
  value       = google_compute_network.shared_vpc.self_link
}

output "project_id" {
  description = "Project ID where the VPC is created"
  value       = var.host_project_id
}

output "routing_mode" {
  description = "Routing mode of the VPC"
  value       = google_compute_network.shared_vpc.routing_mode
}

output "mtu" {
  description = "MTU configured on the VPC"
  value       = google_compute_network.shared_vpc.mtu
}
