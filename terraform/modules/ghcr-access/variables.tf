# Variables for GitHub Container Registry Access module

variable "github_username" {
  description = "GitHub username for Container Registry authentication (not needed with OIDC)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_token" {
  description = "GitHub token for Container Registry authentication (used as fallback)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "namespaces" {
  description = "List of Kubernetes namespaces where the service account should be created"
  type        = list(string)
  default     = ["default", "argocd"]
}

variable "eks_role_arn" {
  description = "ARN of the IAM role for EKS service account (used as fallback)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "create_github_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider (set to false if it already exists)"
  type        = bool
  default     = false
}

variable "create_github_actions_role" {
  description = "Whether to create the GitHub Actions IAM role (set to false if it already exists)"
  type        = bool
  default     = false
}
