variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "eks_cluster_certificate_authority_data" {
  description = "EKS cluster CA data"
  type        = string
}

variable "eks_auth_token" {
  description = "EKS auth token"
  type        = string
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password"
  type        = string
  default     = null
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "datascientest-fastapi-project-group-25"
}

variable "release_repo" {
  description = "Release repository name"
  type        = string
  default     = "fastAPI-project-release"
}
