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

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table for state locking"
  default     = "terraform-lock"
}

variable "use_localstack" {
  type        = bool
  description = "Whether to use LocalStack for local development"
  default     = true
}
