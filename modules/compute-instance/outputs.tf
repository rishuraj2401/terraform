############################################
# Kubernetes Master Outputs
############################################

output "k8s_master_name" {
  description = "Name of the Kubernetes master instance"
  value       = google_compute_instance.k8s_master.name
}

output "k8s_master_internal_ip" {
  description = "Internal IP address of the Kubernetes master"
  value       = google_compute_instance.k8s_master.network_interface[0].network_ip
}

output "k8s_master_self_link" {
  description = "Self-link of the Kubernetes master instance"
  value       = google_compute_instance.k8s_master.self_link
}

############################################
# Kubernetes Worker Outputs
############################################

output "k8s_worker_names" {
  description = "Names of the Kubernetes worker instances"
  value       = [for w in google_compute_instance.k8s_workers : w.name]
}

output "k8s_worker_internal_ips" {
  description = "Internal IP addresses of the Kubernetes worker instances"
  value       = [for w in google_compute_instance.k8s_workers : w.network_interface[0].network_ip]
}

output "k8s_worker_self_links" {
  description = "Self-links of the Kubernetes worker instances"
  value       = [for w in google_compute_instance.k8s_workers : w.self_link]
}

############################################
# Backend Services Outputs
############################################

output "backend_service_names" {
  description = "Names of backend service instances"
  value       = { for k, v in google_compute_instance.backend_services : k => v.name }
}

output "backend_service_internal_ips" {
  description = "Internal IPs of backend service instances"
  value       = { for k, v in google_compute_instance.backend_services : k => v.network_interface[0].network_ip }
}

output "backend_service_self_links" {
  description = "Self-links of backend service instances"
  value       = { for k, v in google_compute_instance.backend_services : k => v.self_link }
}

############################################
# Disk Outputs (Optional but Useful)
############################################

output "k8s_worker_data_disk_names" {
  description = "Names of Kubernetes worker data disks"
  value       = [for d in google_compute_disk.k8s_worker_data_disk : d.name]
}

output "backend_data_disk_names" {
  description = "Names of backend service data disks"
  value       = { for k, d in google_compute_disk.backend_data_disk : k => d.name }
}

############################################
# Debug / Wiring Helpers (Root Module)
############################################

output "zone" {
  description = "Zone where compute instances are deployed"
  value       = var.zone
}

output "project_id" {
  description = "Project ID where compute instances are deployed"
  value       = var.project_id
}
