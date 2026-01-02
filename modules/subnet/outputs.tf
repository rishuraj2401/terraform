# modules/subnet/outputs.tf
# Outputs for Subnet Module (Self-managed Kubernetes)

############################################
# Kubernetes Subnet Outputs
############################################

output "kubernetes_subnet_id" {
  description = "ID of the Kubernetes subnet (existing or newly managed)"
  value       = google_compute_subnetwork.kubernetes_subnet.id
}

output "kubernetes_subnet_name" {
  description = "Name of the Kubernetes subnet"
  value       = google_compute_subnetwork.kubernetes_subnet.name
}

output "kubernetes_subnet_self_link" {
  description = "Self-link of the Kubernetes subnet (used by compute, firewall, routes)"
  value       = google_compute_subnetwork.kubernetes_subnet.self_link
}

output "kubernetes_subnet_cidr" {
  description = "Primary CIDR range of the Kubernetes subnet (secondary ranges ignored)"
  value       = google_compute_subnetwork.kubernetes_subnet.ip_cidr_range
}

############################################
# Backend Services Subnet Outputs
############################################

output "backend_subnet_id" {
  description = "ID of the backend services subnet"
  value       = google_compute_subnetwork.backend_subnet.id
}

output "backend_subnet_name" {
  description = "Name of the backend services subnet"
  value       = google_compute_subnetwork.backend_subnet.name
}

output "backend_subnet_self_link" {
  description = "Self-link of the backend services subnet"
  value       = google_compute_subnetwork.backend_subnet.self_link
}

output "backend_subnet_cidr" {
  description = "CIDR range of the backend services subnet"
  value       = google_compute_subnetwork.backend_subnet.ip_cidr_range
}

############################################
# Reserved Internal IP Outputs – Kubernetes
############################################

output "k8s_master_ip_address" {
  description = "Reserved internal IP address for Kubernetes master node"
  value       = google_compute_address.k8s_master_ip.address
}

output "k8s_master_ip_name" {
  description = "Resource name of the reserved IP for Kubernetes master"
  value       = google_compute_address.k8s_master_ip.name
}

output "k8s_worker_ip_addresses" {
  description = "List of reserved internal IP addresses for Kubernetes worker nodes"
  value       = [for ip in google_compute_address.k8s_worker_ips : ip.address]
}

output "k8s_worker_ip_names" {
  description = "List of resource names for reserved IPs of Kubernetes worker nodes"
  value       = [for ip in google_compute_address.k8s_worker_ips : ip.name]
}

############################################
# Reserved Internal IP Outputs – Backend
############################################

output "backend_service_ip_addresses" {
  description = "Map of backend service names to their reserved internal IP addresses"
  value       = {
    for service, ip in google_compute_address.backend_service_ips :
    service => ip.address
  }
}

############################################
# Design / Debug Outputs (Optional but Useful)
############################################

output "subnet_region" {
  description = "Region where subnets are created"
  value       = var.region
}

output "vpc_network_self_link" {
  description = "Self-link of the VPC network used by subnets"
  value       = var.network_self_link
}
