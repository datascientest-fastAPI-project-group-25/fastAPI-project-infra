# Get the GitHub Machine User PAT from AWS Secrets Manager
data "aws_secretsmanager_secret" "github_token" {
  name = var.machine_user_token_secret_name
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

# Use local variable with static keys for namespaces
locals {
  # Define static namespace map based on environment
  namespace_map = {
    "fastapi-helm-${var.environment}" = "app-namespace"
    "argocd-${var.environment}"       = "argocd-namespace"
    "default"                         = "default-namespace"
  }

  # Filter the map to only include namespaces that are in the var.namespaces list
  filtered_namespaces = {
    for ns_key, ns_desc in local.namespace_map :
    ns_key => ns_desc if contains(var.namespaces, ns_key)
  }
}

# Create a Kubernetes secret for GHCR authentication in each namespace
resource "kubernetes_secret" "ghcr_auth" {
  for_each = local.filtered_namespaces

  metadata {
    name      = "ghcr-secret"
    namespace = each.key
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
      "description"                  = each.value
    }
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          auth = base64encode("${var.github_org}:${data.aws_secretsmanager_secret_version.github_token.secret_string}")
        }
      }
    })
  }
}