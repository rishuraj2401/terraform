# environments/prod/outputs.tf

# VPC Outputs
output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = module.shared_vpc.network_name
}

output "vpc_network_self_link" {
  description = "Self-link of the VPC network"
  value       = module.shared_vpc.network_self_link
}

# Subnet Outputs
output "kubernetes_subnet_name" {
  description = "Name of the Kubernetes subnet"
  value       = module.subnets.kubernetes_subnet_name
}

output "kubernetes_subnet_cidr" {
  description = "CIDR of the Kubernetes subnet"
  value       = module.subnets.kubernetes_subnet_cidr
}

output "backend_subnet_name" {
  description = "Name of the backend services subnet"
  value       = module.subnets.backend_subnet_name
}

output "backend_subnet_cidr" {
  description = "CIDR of the backend services subnet"
  value       = module.subnets.backend_subnet_cidr
}

# Kubernetes Master Outputs
output "k8s_master_names" {
  description = "Names of Kubernetes master instances"
  value       = module.compute_instances.k8s_master_names
}

output "k8s_master_internal_ips" {
  description = "Internal IPs of Kubernetes masters"
  value       = module.compute_instances.k8s_master_internal_ips
}

# Backward-compatible single-master outputs (first master)
output "k8s_master_name" {
  description = "Name of the Kubernetes master instance (legacy: first master)"
  value       = module.compute_instances.k8s_master_name
}

output "k8s_master_internal_ip" {
  description = "Internal IP of the Kubernetes master (legacy: first master)"
  value       = module.compute_instances.k8s_master_internal_ip
}

# Kubernetes Workers Outputs
output "k8s_worker_names" {
  description = "Names of Kubernetes worker instances"
  value       = module.compute_instances.k8s_worker_names
}

output "k8s_worker_internal_ips" {
  description = "Internal IPs of Kubernetes workers"
  value       = module.compute_instances.k8s_worker_internal_ips
}

# Backend Services Outputs
output "backend_service_names" {
  description = "Names of backend service instances"
  value       = module.compute_instances.backend_service_names
}

output "backend_service_internal_ips" {
  description = "Internal IPs of backend services"
  value       = module.compute_instances.backend_service_internal_ips
}

# Service Account Outputs
output "k8s_master_sa_email" {
  description = "Email of Kubernetes master service account"
  value       = module.service_accounts.k8s_master_sa_email
}

output "k8s_worker_sa_email" {
  description = "Email of Kubernetes worker service account"
  value       = module.service_accounts.k8s_worker_sa_email
}

output "backend_services_sa_email" {
  description = "Email of backend services service account"
  value       = module.service_accounts.backend_services_sa_email
}

# Storage Outputs
output "terraform_state_bucket_name" {
  description = "Name of Terraform state bucket"
  value       = module.cloud_storage.terraform_state_bucket_name
}

output "backup_bucket_name" {
  description = "Name of backup bucket"
  value       = module.cloud_storage.backup_bucket_name
}

# Artifact Registry Outputs
output "docker_repository_url" {
  description = "URL of Docker repository"
  value       = module.artifact_registry.docker_repository_url
}