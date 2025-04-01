output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = var.use_localstack ? null : try(aws_iam_role.github_actions_bootstrap_role[0].arn, null)
}

output "lambda_function_arn" {
  description = "ARN of the S3 event processor Lambda function"
  value       = var.use_localstack ? null : try(aws_lambda_function.s3_event_lambda[0].arn, null)
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = var.use_localstack ? null : try(aws_iam_role.lambda_role[0].arn, null)
}

output "lambda_function_name" {
  description = "Name of the S3 event processor Lambda function"
  value       = var.use_localstack ? null : try(aws_lambda_function.s3_event_lambda[0].function_name, null)
}