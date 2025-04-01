variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = null # Will use AWS_DEFAULT_REGION from environment
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = null # Will use AWS_ACCOUNT_ID from environment
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = null # Will use ENVIRONMENT from environment variables
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = null # Will use PROJECT_NAME from environment variables
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = null # Will use BOOTSTRAP_STATE_BUCKET from environment
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket for logs"
  type        = string
  default     = null # Will use BOOTSTRAP_LOGS_BUCKET from environment
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = null # Will use BOOTSTRAP_DYNAMODB_TABLE from environment
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "datascientest-fastAPI-project-group-25" # Default for this project
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "fastAPI-project-infra" # Default for this project
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function ZIP file"
  type        = string
  default     = "notification_handler.zip"
}