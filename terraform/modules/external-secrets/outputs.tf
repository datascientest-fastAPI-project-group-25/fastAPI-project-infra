# Outputs for External Secrets Operator module

output "service_account_name" {
  description = "Name of the Kubernetes service account for External Secrets"
  value       = kubernetes_service_account.external_secrets.metadata[0].name
}

output "service_account_namespace" {
  description = "Namespace of the Kubernetes service account for External Secrets"
  value       = kubernetes_service_account.external_secrets.metadata[0].namespace
}

output "iam_role_arn" {
  description = "ARN of the IAM role for External Secrets"
  value       = aws_iam_role.external_secrets.arn
}

output "cluster_secret_store_name" {
  description = "Name of the ClusterSecretStore for AWS Secrets Manager"
  value       = kubernetes_manifest.cluster_secret_store.manifest.metadata.name
}
