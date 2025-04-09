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

# Deploy ArgoCD Application using kubectl
resource "null_resource" "apply_argocd_app" {
  depends_on = [
    helm_release.argocd,
    time_sleep.wait_for_crds
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/argocd-app.yml"
  }
}

# Create namespaces for each environment
resource "kubernetes_namespace" "environments" {
  for_each = toset(["dev", "staging", "prod"])

  metadata {
    name = "fastapi-helm-${each.key}"
  }

  depends_on = [helm_release.argocd]
}

# Deploy ArgoCD ApplicationSet for multi-environment support
resource "null_resource" "apply_application_set" {
  depends_on = [
    helm_release.argocd,
    time_sleep.wait_for_crds,
    null_resource.apply_argocd_app,
    kubernetes_namespace.environments
  ]

  # Apply the ApplicationSet with explicit environment definitions
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/templates/application-set-environments.yml"
  }
}
