variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

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

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the EKS cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # This should be restricted in production
}
