variable "use_localstack" {
  description = "Whether to use LocalStack instead of real AWS services"
  type        = bool
  default     = false
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}