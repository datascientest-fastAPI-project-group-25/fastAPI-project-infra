terraform {
  backend "local" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # LocalStack specific settings
  access_key = "test"
  secret_key = "test"

  # LocalStack endpoint configurations
  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    iam      = "http://localhost:4566"
    lambda   = "http://localhost:4566"
  }

  # Skip credential validation and region lookup
  skip_credentials_validation = true
  skip_metadata_api_check    = true
  skip_requesting_account_id = true

  # Disable TLS validation
  insecure = true
}

locals {
  state_bucket_name = "localstack-s3-bucket"
  logs_bucket_name = "localstack-logs-bucket"
}

module "state" {
  source = "../../modules/state"

  use_localstack      = true
  dynamodb_table_name = var.dynamodb_table_name
  s3_bucket_name      = local.state_bucket_name
  aws_region         = var.aws_region
  environment        = var.environment
  project_name       = var.project_name
}

module "logging" {
  source = "../../modules/logging"

  use_localstack    = true
  logs_bucket_name  = local.logs_bucket_name
  state_bucket_id   = module.state.state_bucket_id
  aws_region        = var.aws_region
  environment       = var.environment
  project_name      = var.project_name
}

# Security module is minimal in local environment
module "security" {
  source = "../../modules/security"

  use_localstack    = true
  github_org        = var.github_org
  github_repo       = var.github_repo
  environment       = var.environment
  project_name      = var.project_name
  state_bucket_arn  = module.state.state_bucket_arn
  state_bucket_id   = module.state.state_bucket_id
  lambda_zip_path   = var.lambda_zip_path
  aws_region        = var.aws_region
  aws_account_id    = var.aws_account_id
  resource_arns     = ["*"]  # Less restrictive for local development
}

# Create local directories to simulate S3 buckets
resource "null_resource" "local_directories" {
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p local-infra/s3-buckets/state
      mkdir -p local-infra/s3-buckets/logs
      echo "# Local Infrastructure Setup" > README.md
      echo "" >> README.md
      echo "This directory contains simulated AWS resources for local development." >> README.md
    EOT
  }
}
