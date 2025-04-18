# ArgoCD Module
# This module deploys ArgoCD to the EKS cluster

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.46.7"  # Specify a version for stability

  values = [
    file("${path.module}/argocd-values.yml")
  ]

  # Wait for ArgoCD to be ready
  timeout = 1800
}

# Wait for ArgoCD CRDs to be available
resource "time_sleep" "wait_for_crds" {
  depends_on = [helm_release.argocd]
  create_duration = "300s"
}

# Deploy ArgoCD Application using Kubernetes provider
resource "kubernetes_manifest" "argocd_application" {
  depends_on = [
    helm_release.argocd,
    time_sleep.wait_for_crds
  ]

  manifest = yamldecode(file("${path.module}/argocd-app.yml"))

  field_manager {
    # Set force conflicts to true to override any conflicts with other controllers
    force_conflicts = true
  }
}
