output "namespace" {
  description = "The Kubernetes namespace for the FastAPI application"
  value       = kubernetes_namespace.fastapi.metadata[0].name
}

# GHCR secret is now managed by the ghcr-secret module

output "db_secret_name" {
  description = "The name of the database credentials secret"
  value       = kubernetes_secret.db_secret.metadata[0].name
}
