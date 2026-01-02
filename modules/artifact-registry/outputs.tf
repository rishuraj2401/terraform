# modules/artifact-registry/outputs.tf

output "docker_repository_id" {
  description = "ID of the Docker repository"
  value       = google_artifact_registry_repository.docker_repo.repository_id
}

output "docker_repository_name" {
  description = "Full name of the Docker repository"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "docker_repository_url" {
  description = "URL of the Docker repository"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "additional_repository_urls" {
  description = "URLs of additional repositories"
  value = {
    for k, v in google_artifact_registry_repository.additional_repos :
    k => "${var.location}-${lower(v.format)}.pkg.dev/${var.project_id}/${v.repository_id}"
  }
}