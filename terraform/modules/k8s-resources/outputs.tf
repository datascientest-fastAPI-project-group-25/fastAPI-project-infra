output "namespace" {
  description = "The Kubernetes namespace for the FastAPI application"
  value       = kubernetes_namespace.fastapi.metadata[0].name
}

output "ghcr_secret_name" {
  description = "The name of the GitHub Container Registry secret"
  value       = kubernetes_secret.ghcr_secret.metadata[0].name
}

output "db_secret_name" {
  description = "The name of the database credentials secret"
  value       = kubernetes_secret.db_secret.metadata[0].name
}
