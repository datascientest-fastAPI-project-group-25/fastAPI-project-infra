variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  default     = "575977136211" # Default value to avoid prompting
}
