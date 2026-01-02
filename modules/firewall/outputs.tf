output "allow_internal_rule_name" {
  description = "Name of the allow internal traffic firewall rule"
  value       = try(google_compute_firewall.allow_internal[0].name, null)
}

output "allow_k8s_api_rule_name" {
  description = "Name of the allow Kubernetes API firewall rule"
  value       = google_compute_firewall.allow_k8s_api.name
}

output "allow_iap_ssh_rule_name" {
  description = "Name of the allow IAP SSH firewall rule"
  value       = try(google_compute_firewall.allow_iap_ssh[0].name, null)
}

output "allow_health_checks_rule_name" {
  description = "Name of the allow health checks firewall rule"
  value       = try(google_compute_firewall.allow_health_checks[0].name, null)
}
