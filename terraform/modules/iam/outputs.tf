output "iam_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "GitHub Actions IAM Role ARN"
}

output "iam_role_name" {
  value       = aws_iam_role.github_actions.name
  description = "GitHub Actions IAM Role Name"
}

output "github_oidc_provider_arn" {
  value       = var.github_oidc_provider_arn
  description = "GitHub OIDC Provider ARN"
}
