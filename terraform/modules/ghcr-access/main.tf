# GitHub Container Registry Access Module
# This module creates Kubernetes secrets for pulling images from GitHub Container Registry

# Create Kubernetes secret for GitHub Container Registry access
resource "kubernetes_secret" "ghcr_secret" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-secret"
    namespace = each.value
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

# Create Kubernetes service account for pulling images
resource "kubernetes_service_account" "ghcr_service_account" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-service-account"
    namespace = each.value
    annotations = {
      "eks.amazonaws.com/role-arn" = var.eks_role_arn
    }
  }

  image_pull_secret {
    name = kubernetes_secret.ghcr_secret[each.value].metadata[0].name
  }
}

# Create Kubernetes role for pulling images
resource "kubernetes_role" "ghcr_role" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-role"
    namespace = each.value
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create Kubernetes role binding for pulling images
resource "kubernetes_role_binding" "ghcr_role_binding" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-role-binding"
    namespace = each.value
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ghcr_role[each.value].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ghcr_service_account[each.value].metadata[0].name
    namespace = each.value
  }
}
