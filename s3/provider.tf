terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.replica]
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "replica"
  region = var.replica_region
}
