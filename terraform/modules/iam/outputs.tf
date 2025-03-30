output "github_actions_role_name" {
  description = "GitHub Actions IAM Role Name"
  value       = aws_iam_role.github_actions.name
}

output "github_actions_role_arn" {
  description = "GitHub Actions IAM Role ARN"
  value       = aws_iam_role.github_actions.arn
}

output "lambda_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_role.arn
}
