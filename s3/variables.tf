variable "bucket_name" {
  description = "S3 bucket for terraform state"
  type        = string
  default     = "dst-project-group-25-terraform-state"
}

variable "replica_region" {
  description = "AWS region for the replica bucket"
  type        = string
  default     = "eu-central-1"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "575977136211" # Your AWS account ID
}


variable "github_actions_role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
}
