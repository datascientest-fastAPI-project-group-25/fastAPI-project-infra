variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "fastapi-project"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16" # Different CIDR for production
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the EKS cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"] # This should be restricted in production
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "eks_node_group_instance_types" {
  description = "Instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.large"] # Larger instances for production
}

variable "eks_node_group_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
  default     = 3
}

variable "eks_node_group_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
  default     = 2
}

variable "eks_node_group_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
  default     = 6
}

variable "github_username" {
  description = "GitHub username for container registry access"
  type        = string
}

variable "github_token" {
  description = "GitHub token for container registry access"
  type        = string
  sensitive   = true
}

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

variable "rds_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.medium" # Larger instance for production
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB for RDS"
  type        = number
  default     = 20 # More storage for production
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage in GB for RDS autoscaling"
  type        = number
  default     = 100 # More max storage for production
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

variable "github_repo" {
  description = "Full GitHub repository path (e.g., org-name/repo-name)"
  type        = string
  default     = "datascientest-fastapi-project-group-25/fastAPI-project-infra"
}
