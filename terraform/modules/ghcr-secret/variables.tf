variable "environment" {
  description = "Environment name (e.g., stg, prod)"
  type        = string
}

variable "namespaces" {
  description = "List of Kubernetes namespaces where the GHCR secret should be created"
  type        = list(string)
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "machine_user_token_secret_name" {
  description = "Name of the AWS Secrets Manager secret containing the GitHub Machine User PAT"
  type        = string
  default     = "github/machine-user-token"
}