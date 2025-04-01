variable "use_localstack" {
  description = "Whether to use LocalStack instead of real AWS services"
  type        = bool
  default     = false
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
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

variable "state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  type        = string
}

variable "state_bucket_id" {
  description = "ID of the Terraform state bucket"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function ZIP file"
  type        = string
}

variable "resource_arns" {
  description = "List of resource ARNs that GitHub Actions role can access"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
