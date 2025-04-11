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
