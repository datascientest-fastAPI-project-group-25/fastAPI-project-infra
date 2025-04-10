# ================================
# Shared Variable Definitions
# ================================

# This file defines common variables that are used across all environments
# It can be included in each environment's configuration

# AWS configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fastapi-project"
}

# GitHub credentials
variable "github_username" {
  description = "GitHub username for Container Registry authentication"
  type        = string
}

variable "github_token" {
  description = "GitHub token for Container Registry authentication"
  type        = string
  sensitive   = true
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "datascientest-fastapi-project-group-25"
}

variable "release_repo" {
  description = "GitHub repository name for releases"
  type        = string
  default     = "fastAPI-project-release"
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
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "postgres"
}

# EKS configuration
variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.27"
}

# Note: Environment-specific variables like instance types and sizes
# should be defined in each environment's variables.tf file.
