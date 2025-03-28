terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
  # For local development, credentials are loaded from environment variables
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  # For GitHub Actions, OIDC is used to assume the GitHubActionsRole("FastAPIProjectInfraRole" in this case)
  # The role is assumed by the GitHub Actions runner, so no need to provide credentials
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_oidc.html
}

provider "aws" {
  alias  = "replica"
  region = "eu-central-1" # Different region for replication
}
