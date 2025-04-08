# ================================
# Variables (variables.tf)
# ================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "datascientest-fastAPI-project-group-25"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "fastAPI-project-release"
}

variable "argocd_app_name" {
  description = "Name of the ArgoCD application"
  type        = string
  default     = "fastapi-app"
}

variable "argocd_app_path" {
  description = "Path to the application in the Git repository"
  type        = string
  default     = "helm"
}
