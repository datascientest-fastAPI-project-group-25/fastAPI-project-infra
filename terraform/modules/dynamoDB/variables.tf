# /terraform/modules/dynamodb/variables.tf

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "terraform-state-lock"
}
