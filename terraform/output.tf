# Output kubeconfig for debugging (optional)
output "kubeconfig" {
  value = module.eks.kubeconfig
  sensitive = true
}