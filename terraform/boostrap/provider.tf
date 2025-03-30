terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  # Backend configuration will be provided via -backend-config
}

# Provider configuration for LocalStack
provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # LocalStack endpoints (only applied when use_localstack = true)
  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      dynamodb = "http://localhost:4566"
      s3       = "http://localhost:4566"
    }
  }
}
