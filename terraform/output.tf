#output "iam_role_arn" {
# value       = aws_iam_role.github_actions.arn
#description = "GitHub Actions IAM Role ARN"
#}

output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Terraform State S3 Bucket Name"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "Terraform State Lock DynamoDB Table Name"
}
