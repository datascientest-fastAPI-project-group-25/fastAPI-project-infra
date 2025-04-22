variable "namespace" {
  description = "Kubernetes namespace for the FastAPI application"
  type        = string
}

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

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
}

variable "use_external_db" {
  description = "Whether to use an external database (RDS) or in-cluster PostgreSQL"
  type        = bool
  default     = false
}

variable "db_host" {
  description = "External database host (used when use_external_db is true)"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "External database port (used when use_external_db is true)"
  type        = number
  default     = 5432
}
