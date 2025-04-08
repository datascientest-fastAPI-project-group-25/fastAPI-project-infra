variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fastapi-project"
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  type        = string
  default     = ""
}

variable "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  type        = string
  default     = ""
}

variable "eks_auth_token" {
  description = "Authentication token for EKS cluster"
  type        = string
  sensitive   = true
  default     = ""
}
