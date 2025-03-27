output "local_state_directory" {
  description = "The local directory path for Terraform state storage"
  value       = "local-infra/s3-buckets/state"
}

output "local_logs_directory" {
  description = "The local directory path for access logs"
  value       = "local-infra/s3-buckets/logs"
}
