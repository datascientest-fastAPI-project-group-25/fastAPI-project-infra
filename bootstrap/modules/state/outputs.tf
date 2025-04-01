output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table for state locking"
  value       = var.use_localstack ? null : try(aws_dynamodb_table.terraform_locks[0].arn, null)
}

output "state_bucket_arn" {
  description = "The ARN of the S3 bucket for Terraform state"
  value       = var.use_localstack ? null : try(aws_s3_bucket.terraform_state[0].arn, null)
}

output "state_bucket_id" {
  description = "The ID of the S3 bucket for Terraform state"
  value       = var.use_localstack ? null : try(aws_s3_bucket.terraform_state[0].id, null)
}

output "state_bucket_region" {
  description = "The region of the S3 bucket for Terraform state"
  value       = var.aws_region
}