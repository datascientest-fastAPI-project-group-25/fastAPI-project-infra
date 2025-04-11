# Kubernetes Resources Module
# This module creates Kubernetes resources required for the FastAPI application

# Create the namespace for the FastAPI application
resource "kubernetes_namespace" "fastapi" {
  metadata {
    name = "fastapi-helm-${var.environment == "development" ? "dev" : var.environment}"

    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

# Create a secret for GitHub Container Registry credentials
resource "kubernetes_secret" "ghcr_secret" {
  metadata {
    name      = "ghcr-secret"
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
  }

  data = {
    username        = var.db_username
    password        = var.db_password
    database        = var.db_name
    host            = var.use_external_db ? var.db_host : "postgres"
    port            = tostring(var.use_external_db ? var.db_port : 5432)
    use_external_db = tostring(var.use_external_db)
    #port     = tostring(var.use_external_db ? var.db_port : 5432)
    #use_external_db = tostring(var.use_external_db)
  }
}
