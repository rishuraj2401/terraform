# modules/subnets/outputs.tf

############################################
# Kubernetes Subnet Outputs
############################################

output "kubernetes_subnet_id" {
  description = "ID of the Kubernetes subnet"
  # FIX: Reference the DATA source, not a resource
  value       = data.google_compute_subnetwork.k8s.id
}

output "kubernetes_subnet_name" {
  description = "Name of the Kubernetes subnet"
  value       = data.google_compute_subnetwork.k8s.name
}

output "kubernetes_subnet_self_link" {
  description = "Self-link of the Kubernetes subnet"
  value       = data.google_compute_subnetwork.k8s.self_link
}

output "kubernetes_subnet_cidr" {
  description = "Primary CIDR range of the Kubernetes subnet"
  value       = data.google_compute_subnetwork.k8s.ip_cidr_range
}

############################################
# Backend Services Subnet Outputs
############################################

output "backend_subnet_id" {
  description = "ID of the backend services subnet"
  # FIX: Reference the DATA source
  value       = data.google_compute_subnetwork.backend.id
}

output "backend_subnet_name" {
  description = "Name of the backend services subnet"
  value       = data.google_compute_subnetwork.backend.name
}

output "backend_subnet_self_link" {
  description = "Self-link of the backend services subnet"
  value       = data.google_compute_subnetwork.backend.self_link
}

output "backend_subnet_cidr" {
  description = "CIDR range of the backend services subnet"
  value       = data.google_compute_subnetwork.backend.ip_cidr_range
}

############################################
# Reserved Internal IP Outputs – Kubernetes
############################################

output "k8s_master_ip_address" {
  description = "Reserved internal IP address for Kubernetes master node"
  # These references remain the same as they are still Resources created by this module
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
# Design / Debug Outputs
############################################

output "subnet_region" {
  description = "Region where subnets are located"
  value       = var.region
}

output "vpc_network_self_link" {
  description = "Self-link of the VPC network used by subnets"
  # FIX: We fetch this from the data source now, since var.network_self_link was removed
  value       = data.google_compute_subnetwork.k8s.network
}