# ArgoCD Module
# This module installs and configures ArgoCD in the EKS cluster

# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd-${var.environment}"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd-${var.environment}"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.51.4"

  values = [
    file("${path.module}/argocd-values.yml")
  ]

  # Set environment-specific values
  set {
    name  = "server.env[0].name"
    value = "ENVIRONMENT"
  }

  set {
    name  = "server.env[0].value"
    value = var.environment
  }

  depends_on = [kubernetes_namespace.argocd]
}

# Create ApplicationSet template file
resource "local_file" "application_set" {
  content = templatefile("${path.module}/templates/application-set.yml", {
    environment     = var.environment
    github_org      = var.github_org
    release_repo    = var.release_repo
    target_revision = "main"
  })
  filename = "${path.module}/.terraform/application-set-${var.environment}.yml"
}

# Apply the ApplicationSet
resource "kubernetes_manifest" "application_set" {
  manifest = yamldecode(local_file.application_set.content)

  depends_on = [
    helm_release.argocd,
    local_file.application_set
  ]
}
