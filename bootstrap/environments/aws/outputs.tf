output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.state.state_bucket_id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = module.state.state_bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = var.dynamodb_table_name
}

output "logs_bucket_name" {
  description = "Name of the S3 bucket for logs"
  value       = module.logging.logs_bucket_name
}

output "logs_bucket_arn" {
  description = "ARN of the S3 bucket for logs"
  value       = module.logging.logs_bucket_arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = module.security.github_actions_role_arn
}

output "lambda_function_name" {
  description = "Name of the S3 event processor Lambda function"
  value       = module.security.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the S3 event processor Lambda function"
  value       = module.security.lambda_function_arn
}