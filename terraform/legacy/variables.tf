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

# GitHub Container Registry credentials
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

# Database credentials
variable "db_username" {
  description = "Database username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "postgres"
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
