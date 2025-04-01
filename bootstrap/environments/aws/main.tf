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
  s3_bucket_name = "fastapi-project-terraform-state-${var.aws_account_id}"
  logs_bucket_name = "fastapi-project-terraform-logs-${var.aws_account_id}"
}

module "state" {
  source = "../../modules/state"

  use_localstack      = false
  dynamodb_table_name = var.dynamodb_table_name
  s3_bucket_name      = local.s3_bucket_name
  aws_region         = var.aws_region
  environment        = var.environment
  project_name       = var.project_name
}

module "logging" {
  source = "../../modules/logging"

  use_localstack    = false
  logs_bucket_name  = local.logs_bucket_name
  state_bucket_id   = module.state.state_bucket_id
  aws_region        = var.aws_region
  environment       = var.environment
  project_name      = var.project_name
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
  aws_region        = var.aws_region

  resource_arns = [
    module.state.state_bucket_arn,
    module.state.dynamodb_table_arn,
    "arn:aws:iam::${var.aws_account_id}:role/*"
  ]
}