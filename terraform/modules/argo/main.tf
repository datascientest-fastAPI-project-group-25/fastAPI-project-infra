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

# Render the ApplicationSet template
data "template_file" "application_set" {
  template = file("${path.module}/templates/application-set.yml")
  vars = {
    environment     = var.environment
    github_org      = var.github_org
    release_repo    = var.release_repo
    target_revision = "main"
  }
}

# Save the rendered ApplicationSet template
resource "local_file" "application_set" {
  content  = data.template_file.application_set.rendered
  filename = "${path.module}/rendered-application-set.yml"
}

# Deploy ArgoCD ApplicationSet using kubectl
resource "null_resource" "apply_argocd_app" {
  depends_on = [
    helm_release.argocd,
    time_sleep.wait_for_crds,
    local_file.application_set
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/rendered-application-set.yml"
  }
}
