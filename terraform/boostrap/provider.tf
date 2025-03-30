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

provider "aws" {
  region = var.aws_region

  # Assume OIDC Role only when not using LocalStack
  dynamic "assume_role" {
    for_each = var.use_localstack ? [] : [1]
    content {
      role_arn = module.iam.github_actions_role_arn
    }
  }

  # Skip credential validation when using LocalStack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # LocalStack endpoints setup
  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      s3     = "http://localhost:4566"
      lambda = "http://localhost:4566"
      dynamodb = "http://localhost:4566"
    }
  }
}
