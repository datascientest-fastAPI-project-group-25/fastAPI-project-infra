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
}

# We'll deploy the ArgoCD Application manually after the cluster is up
# This avoids the issue with the Application CRD not being ready