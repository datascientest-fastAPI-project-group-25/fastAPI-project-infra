# Variables for GitHub Container Registry Access module

variable "github_username" {
  description = "GitHub username for Container Registry authentication"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub token for Container Registry authentication"
  type        = string
  sensitive   = true
}

variable "namespaces" {
  description = "List of Kubernetes namespaces where the secret should be created"
  type        = list(string)
  default     = ["fastapi-helm-dev", "fastapi-helm-staging", "fastapi-helm-prod"]
}

variable "eks_role_arn" {
  description = "ARN of the IAM role for EKS service account"
  type        = string
}
