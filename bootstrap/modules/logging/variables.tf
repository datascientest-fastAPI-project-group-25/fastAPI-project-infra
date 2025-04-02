variable "use_localstack" {
  description = "Whether to use LocalStack instead of real AWS services"
  type        = bool
  default     = false
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket for storing logs"
  type        = string
}

variable "state_bucket_id" {
  description = "ID of the Terraform state bucket to configure logging for"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
