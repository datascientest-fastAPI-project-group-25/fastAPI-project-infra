output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "logging_bucket_id" {
  description = "The ID of the logging bucket"
  value       = aws_s3_bucket.logging_bucket.id
}

output "s3_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption"
  value       = aws_kms_key.s3_key.arn
}
