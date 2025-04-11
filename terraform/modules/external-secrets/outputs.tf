# Outputs for External Secrets Operator module

output "namespace" {
  description = "Namespace where External Secrets Operator is installed"
  value       = kubernetes_namespace.external_secrets.metadata[0].name
}

output "role_arn" {
  description = "ARN of the IAM role for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}
