output "secret_names" {
  description = "Map of namespace to secret name for the created GHCR secrets"
  value = {
    for ns_key, _ in local.filtered_namespaces : ns_key => kubernetes_secret.ghcr_auth[ns_key].metadata[0].name
  }
}

output "namespaces" {
  description = "List of namespaces where GHCR secrets were created"
  value       = keys(local.filtered_namespaces)
}

output "environment" {
  description = "Environment name where secrets were created"
  value       = var.environment
}