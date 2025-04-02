variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  default     = "575977136211" # Default value, can be overridden
}

variable "aws_region" {
  type        = string
  description = "AWS region"
 
  default     = "eu-west-2"
}

variable "github_actions_role_name" {
  type        = string
  description = "Name of the IAM role for GitHub Actions"
  default     = "fastapi-project-bootstrap-oidc-role" # Match the role name used in the GitHub Actions workflow
}

variable "github_org" {
  type        = string
  description = "GitHub organization name"
  default     = "datascientest-fastAPI-project-group-25"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
  default     = "fastAPI-project-infra" # Default value, can be overridden
}

variable "github_actions_oidc_arn" {
  type        = string
  description = "ARN of the GitHub Actions OIDC provider"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table for state locking"
  default     = "terraform-lock"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Project name for tagging"
  default     = "fastapi-project"
}
