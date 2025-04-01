output "logs_bucket_arn" {
  description = "The ARN of the logging bucket"
  value       = var.use_localstack ? null : try(aws_s3_bucket.logging_bucket[0].arn, null)
}

output "logs_bucket_id" {
  description = "The ID of the logging bucket"
  value       = var.use_localstack ? null : try(aws_s3_bucket.logging_bucket[0].id, null)
}

output "logs_bucket_name" {
  description = "The name of the logging bucket"
  value       = var.logs_bucket_name
}