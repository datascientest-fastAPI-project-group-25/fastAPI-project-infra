variable "github_repo" {
  description = "GitHub repository path (org/repo)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}
