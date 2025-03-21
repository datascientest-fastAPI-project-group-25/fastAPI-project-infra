terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "eu-west-2"
  # For local development, credentials are loaded from environment variables
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  # For GitHub Actions, OIDC is used to assume the GitHubActionsRole
}
