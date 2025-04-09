variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (development, staging, production)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "eks_security_group_ids" {
  description = "List of EKS security group IDs that need access to the database"
  type        = list(string)
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Password for the database (leave empty to generate a random one)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "postgres"
}

variable "postgres_version" {
  description = "Version of PostgreSQL to use"
  type        = string
  default     = "14.8"
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB for autoscaling"
  type        = number
  default     = 100
}
