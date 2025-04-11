# Outputs for GitHub Container Registry Access module

output "service_account_names" {
  description = "Names of the Kubernetes service accounts for GitHub Container Registry access"
  value       = { for ns in var.namespaces : ns => kubernetes_service_account.ghcr_service_account[ns].metadata[0].name }
}

output "secret_names" {
  description = "Names of the Kubernetes secrets for GitHub Container Registry access"
  value       = { for ns in var.namespaces : ns => kubernetes_secret.ghcr_secret[ns].metadata[0].name }
}
