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
  # Uncomment this block when migrating to AWS
  # backend "s3" {
  #   # Configuration will be provided via backend.hcl
  # }
}

# Provider configuration for LocalStack
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # LocalStack endpoints
  endpoints {
    dynamodb = "http://localhost:4566"
    s3       = "http://localhost:4566"
  }
}

# Uncomment and modify this provider block when using actual AWS
# provider "aws" {
#   region = "us-east-1"
#   # Add any additional configuration as needed
# }
