output "secret_names" {
  description = "Map of namespace to secret name for the created GHCR secrets"
  value = {
    for ns in var.namespaces : ns => kubernetes_secret.ghcr_auth[ns].metadata[0].name
  }
}

output "namespaces" {
  description = "List of namespaces where GHCR secrets were created"
  value       = var.namespaces
}

output "environment" {
  description = "Environment name where secrets were created"
  value       = var.environment
}