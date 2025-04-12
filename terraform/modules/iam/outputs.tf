# Outputs for IAM module

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "terraform_state_access_policy_arn" {
  description = "ARN of the IAM policy for Terraform state access"
  value       = aws_iam_policy.terraform_state_access.arn
}

output "ecr_access_policy_arn" {
  description = "ARN of the IAM policy for ECR access"
  value       = aws_iam_policy.ecr_access.arn
}
