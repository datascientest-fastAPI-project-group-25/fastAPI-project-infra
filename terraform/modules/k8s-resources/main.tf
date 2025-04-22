# Kubernetes Resources Module
# This module creates Kubernetes resources required for the FastAPI application

# Create the namespace for the FastAPI application
resource "kubernetes_namespace" "fastapi" {
  metadata {
    name = var.namespace
  }
}

# Create a secret for GitHub Container Registry credentials
resource "kubernetes_secret" "ghcr_secret" {
  count = var.github_username != "" && var.github_token != "" ? 1 : 0

  metadata {
    name      = "ghcr-legacy-secret"  # Renamed to avoid conflict with new ghcr-secret module
    namespace = kubernetes_namespace.fastapi.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          auth = base64encode("${var.github_username}:${var.github_token}")
        }
      }
    })
  }
}

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
