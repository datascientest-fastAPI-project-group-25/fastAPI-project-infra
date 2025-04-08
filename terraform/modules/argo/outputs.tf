# Outputs
output "argocd_namespace" {
  description = "The namespace where ArgoCD is deployed"
  value       = helm_release.argocd.namespace
}

output "argocd_name" {
  description = "The name of the ArgoCD release"
  value       = helm_release.argocd.name
}