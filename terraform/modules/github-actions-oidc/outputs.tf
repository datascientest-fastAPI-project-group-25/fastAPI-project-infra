# Outputs for GitHub Container Registry Access module

output "service_account_names" {
  description = "Names of the Kubernetes service accounts for GitHub Container Registry access"
  value       = { for ns in var.namespaces : ns => kubernetes_service_account.ghcr_service_account[ns].metadata[0].name }
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github_existing[0].arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}
