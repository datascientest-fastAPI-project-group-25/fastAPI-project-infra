variable "github_actions_role_name" {
  type        = string
  description = "Name of the IAM role for GitHub Actions"
  #default     = "FastAPIProjectInfraRole" # Match the role name used in the GitHub Actions workflow
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  # default     = "575977136211" # Default value, can be overridden
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub OIDC provider"
  #default     = "arn:aws:iam::575977136211:oidc-provider/token.actions.githubusercontent.com" # Default value, can be overridden
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  #default     = "us-east-1"
} # Default value, can be overridden

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
  default     = "fastapi-project-infra" # Default value, can be overridden
}

variable "github_org" {
  type        = string
  description = "GitHub organization name"
  # default     = "datascientest-fastAPI-project-group-25"

}
