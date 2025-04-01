variable "aws_region" {
  description = "AWS region for LocalStack (doesn't affect actual AWS resources)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "local"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fastapi-project"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "terraform-state-lock-local"
}

variable "github_org" {
  description = "GitHub organization name (not used in local environment)"
  type        = string
  default     = "local-org"
}

variable "github_repo" {
  description = "GitHub repository name (not used in local environment)"
  type        = string
  default     = "local-repo"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function ZIP file"
  type        = string
  default     = "notification_handler.zip"
}