output "state_bucket_name" {
  description = "Name of the local directory simulating S3 bucket for Terraform state"
  value       = local.state_bucket_name
}

output "logs_bucket_name" {
  description = "Name of the local directory simulating S3 bucket for logs"
  value       = local.logs_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the simulated DynamoDB table for state locking"
  value       = var.dynamodb_table_name
}

output "local_state_directory" {
  description = "Path to local directory simulating state bucket"
  value       = "local-infra/s3-buckets/state"
}

output "local_logs_directory" {
  description = "Path to local directory simulating logs bucket"
  value       = "local-infra/s3-buckets/logs"
}

output "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  value       = "http://localhost:4566"
}
