variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The AWS account ID must be exactly 12 digits."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.bucket_name)) && !can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters long, contain only lowercase letters, numbers, dots, and hyphens, and cannot be an IP address"
  }
}
