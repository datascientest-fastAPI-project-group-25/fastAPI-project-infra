# Variables for External Secrets Operator module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "eks_oidc_provider" {
  description = "EKS OIDC provider URL without https:// prefix"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  type        = string
}
