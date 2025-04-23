# Get the GitHub Machine User PAT from AWS Secrets Manager
data "aws_secretsmanager_secret" "github_token" {
  name = var.machine_user_token_secret_name
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

# Create a Kubernetes secret for GHCR authentication in each namespace
resource "kubernetes_secret" "ghcr_auth" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-secret"
    namespace = each.value
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          auth = base64encode("${var.github_username != "" ? var.github_username : var.github_org}:${data.aws_secretsmanager_secret_version.github_token.secret_string}")
        }
      }
    })
  }
}
