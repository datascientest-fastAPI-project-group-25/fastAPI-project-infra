# Kubernetes Resources Module
# This module creates Kubernetes resources required for the FastAPI application

# Create the namespace for the FastAPI application
resource "kubernetes_namespace" "fastapi" {
  metadata {
    name = var.namespace
  }
}

# Legacy GHCR secret creation removed - now using the ghcr-secret module instead
# which creates a secret named "ghcr-secret" using GitHub PAT from AWS Secrets Manager

# Create a secret for database credentials
resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace.fastapi.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }

  data = merge(
    {
      username = var.db_username
      password = var.db_password
      database = var.db_name
    },
    var.use_external_db ? {
      host = var.db_host
      port = tostring(var.db_port)
    } : {}
  )
}
