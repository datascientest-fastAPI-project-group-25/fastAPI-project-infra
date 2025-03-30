terraform {
  backend "local" {}
}

# Uncomment the following block to use S3 backend
# terraform {
#   backend "s3" {
#     bucket         = "dst-project-group-25-terraform-state"
#     key            = "terraform.tfstate"
#     region         = "eu-west-2"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

provider "aws" {
  region = var.aws_region
  alias  = "main"
}

locals {
  local_state_dir = "local-infra/s3-buckets/state"
  local_logs_dir  = "local-infra/s3-buckets/logs"
  s3_bucket_name = var.use_localstack ? "localstack-s3-bucket" : "dst-project-group-25-s3-bucket"
  logs_bucket_name = var.use_localstack ? "localstack-logs-bucket" : "dst-project-group-25-logs-bucket"
}

# Create local directories to simulate S3 buckets if using LocalStack
resource "null_resource" "local_state_bucket" {
  count = var.use_localstack ? 1 : 0

  provisioner "local-exec" {
    command     = "mkdir -p ${local.local_state_dir}"
    interpreter = ["bash", "-c"]
  }
}

# Create local directories to simulate S3 buckets for logs if using LocalStack
resource "null_resource" "local_logs_bucket" {
  count = var.use_localstack ? 1 : 0

  provisioner "local-exec" {
    command     = "mkdir -p ${local.local_logs_dir}"
    interpreter = ["bash", "-c"]
  }
}

# Create a README file to document the local setup if using LocalStack
resource "null_resource" "local_setup_docs" {
  count = var.use_localstack ? 1 : 0

  provisioner "local-exec" {
    command     = <<-EOT
      cat > README.md << 'EOF'
# Local Terraform State Setup

This directory contains a local simulation of AWS S3 and DynamoDB resources for Terraform state management.

## Directory Structure
- ${local.local_state_dir}: Simulates an S3 bucket for storing Terraform state files
- ${local.local_logs_dir}: Simulates an S3 bucket for storing access logs

## Usage
Use this local setup for development and testing without incurring AWS costs.
EOF
    EOT
    interpreter = ["bash", "-c"]
  }
}

# AWS resources for production (only created when not using LocalStack)
# Create DynamoDB table for state locking first
resource "aws_dynamodb_table" "terraform_locks" {
  count        = var.use_localstack ? 0 : 1
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Create S3 bucket for Terraform state next
resource "aws_s3_bucket" "terraform_state" {
  count  = var.use_localstack ? 0 : 1
  bucket = "fastapi-project-terraform-state-${var.aws_account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for the state bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Skip KMS encryption for now due to permission issues
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# GitHub Actions OIDC Provider
data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

# IAM module (needs to be after S3 and DynamoDB)
module "iam" {
  source = "../modules/iam"

  github_actions_role_name = "fastapi-project-bootstrap-oidc-role"
  aws_account_id           = var.aws_account_id
  github_repo              = "fastAPI-project-infra"
  github_org               = "datascientest-fastAPI-project-group-25"
  aws_region               = var.aws_region
  github_oidc_provider_arn = data.aws_iam_openid_connect_provider.github_actions.arn
}

# Lambda function (needs IAM role)
resource "aws_lambda_function" "s3_event_lambda" {
  count = var.use_localstack ? 0 : 1
  function_name = "s3-event-processor"
  role          = module.iam.lambda_role_arn
  handler       = "notification_handler.lambda_handler"
  runtime       = "nodejs18.x"
  filename      = "notification_handler.zip"
  source_code_hash = filebase64sha256("notification_handler.zip")
}

# S3 bucket notifications (needs Lambda)
resource "aws_s3_bucket_notification" "terraform_state_notifications" {
  depends_on = [aws_lambda_function.s3_event_lambda]
  count      = var.use_localstack ? 0 : 1
  bucket     = aws_s3_bucket.terraform_state[0].id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_event_lambda[0].arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# Lambda permission (needs Lambda)
resource "aws_lambda_permission" "allow_s3_event" {
  count         = var.use_localstack ? 0 : 1
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_lambda[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.terraform_state[0].arn
}

# Logging bucket
resource "aws_s3_bucket" "logging_bucket" {
  count  = var.use_localstack ? 0 : 1
  bucket = "fastapi-project-terraform-logs-${var.aws_account_id}"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# S3 bucket logging
resource "aws_s3_bucket_logging" "terraform_state_logging" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id

  target_bucket = aws_s3_bucket.logging_bucket[0].id
  target_prefix = "logs/"
}

# S3 bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logging_bucket_lifecycle" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.logging_bucket[0].id

  rule {
    id     = "cleanup-old-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}