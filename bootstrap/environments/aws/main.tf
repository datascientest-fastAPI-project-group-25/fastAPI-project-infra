terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  # Use environment variables or fallback to computed values
  aws_region = coalesce(var.aws_region, "eu-west-2")
  s3_bucket_name = coalesce(var.state_bucket_name, "fastapi-project-terraform-state-${var.aws_account_id}")
  logs_bucket_name = coalesce(var.logs_bucket_name, "fastapi-project-terraform-logs-${var.aws_account_id}")
  
  # Common tags
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Repository  = "github.com/${var.github_org}/${var.github_repo}"
  }
}

module "state" {
  source = "../../modules/state"

  use_localstack      = false
  dynamodb_table_name = coalesce(var.dynamodb_table_name, "terraform-state-lock")
  s3_bucket_name      = local.s3_bucket_name
  aws_region         = local.aws_region
  environment        = var.environment
  project_name       = var.project_name
}

module "logging" {
  source = "../../modules/logging"

  use_localstack    = false
  logs_bucket_name  = local.logs_bucket_name
  state_bucket_id   = module.state.state_bucket_id
  aws_region        = local.aws_region
  environment       = var.environment
  project_name       = var.project_name
}

module "security" {
  source = "../../modules/security"

  use_localstack    = false
  github_org        = var.github_org
  github_repo       = var.github_repo
  environment       = var.environment
  project_name      = var.project_name
  state_bucket_arn  = module.state.state_bucket_arn
  state_bucket_id   = module.state.state_bucket_id
  lambda_zip_path   = var.lambda_zip_path
  aws_region        = local.aws_region

  resource_arns = [
    module.state.state_bucket_arn,
    module.state.dynamodb_table_arn,
    "arn:aws:iam::${var.aws_account_id}:role/*"
  ]
}
