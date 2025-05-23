variable "environment" {
  description = "Environment name (e.g., dev, stg, prod)"
  type        = string
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "Full GitHub repository path (e.g., org-name/repo-name)"
  type        = string
}

variable "namespaces" {
  description = "List of Kubernetes namespaces where service accounts should be created"
  type        = list(string)
  default     = ["default"]
}

variable "create_github_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider (set to false if it already exists)"
  type        = bool
  default     = false
}
