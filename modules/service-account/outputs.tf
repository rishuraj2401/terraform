# modules/service-account/outputs.tf

output "k8s_master_sa_email" {
  description = "Email of the Kubernetes master service account"
  value       = google_service_account.k8s_master_sa.email
}

output "k8s_master_sa_id" {
  description = "ID of the Kubernetes master service account"
  value       = google_service_account.k8s_master_sa.id
}

output "k8s_worker_sa_email" {
  description = "Email of the Kubernetes worker service account"
  value       = google_service_account.k8s_worker_sa.email
}

output "k8s_worker_sa_id" {
  description = "ID of the Kubernetes worker service account"
  value       = google_service_account.k8s_worker_sa.id
}

output "backend_services_sa_email" {
  description = "Email of the backend services service account"
  value       = google_service_account.backend_services_sa.email
}

output "backend_services_sa_id" {
  description = "ID of the backend services service account"
  value       = google_service_account.backend_services_sa.id
}
