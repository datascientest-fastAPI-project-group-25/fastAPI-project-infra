provider "aws" {
  region = var.aws_region
  alias  = "main"
}

locals {
  local_state_dir = "local-infra/s3-buckets/state"
  local_logs_dir  = "local-infra/s3-buckets/logs"
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
module "iam" {
  source = "../modules/iam"

  github_actions_role_name = "fastapi-project-bootstrap-oidc-role"
  aws_account_id           = var.aws_account_id
  github_repo              = "fastAPI-project-infra"
  github_org               = "datascientest-fastAPI-project-group-25"
  aws_region               = var.aws_region
  dynamodb_table_name      = var.dynamodb_table_name
}

# AWS resources for production (only created when not using LocalStack)
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

# Create DynamoDB table for state locking
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

resource "aws_lambda_function" "s3_event_lambda" {
  function_name = "s3-event-processor"
  # Skipping specific checks
  # checkov:skip=CKV_AWS_272 Ensure AWS Lambda function is configured to validate code-signing
  # checkov:skip=CKV_AWS_116 Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)
  # checkov:skip=CKV_AWS_115 Ensure that AWS Lambda function is configured for function-level concurrent execution limit
  # checkov:skip=CKV_AWS_117 Ensure that AWS Lambda function is configured inside a VPC
  # checkov:skip=CKV_AWS_50 X-Ray tracing is enabled for Lambda
  runtime  = "python3.9"
  handler  = "notification_handler.lambda_handler"
  role     = module.iam.iam_role_arn
  filename = "notification_handler.zip"
}

resource "aws_s3_bucket_notification" "terraform_state_notifications" {
  depends_on = [aws_lambda_function.s3_event_lambda]
  count      = var.use_localstack ? 0 : 1
  bucket     = aws_s3_bucket.terraform_state[0].id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_event_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_s3_event" {
  count         = var.use_localstack ? 0 : 1
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.terraform_state[0].arn
}

# Logging bucket # Skipping specific checks
# checkov:skip=CKV2_AWS_62 Ensure S3 buckets should have event notifications enabled
# checkov:skip=CKV2_AWS_61 Ensure that an S3 bucket has a lifecycle configuration
# checkov:skip=CKV2_AWS_6 Ensure that S3 bucket has a Public Access block
resource "aws_s3_bucket" "logging_bucket" {
  count  = var.use_localstack ? 0 : 1
  bucket = "fastapi-project-terraform-logs-${var.aws_account_id}"

}

# Enable logging on state bucket
resource "aws_s3_bucket_logging" "terraform_state_logging" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id

  target_bucket = aws_s3_bucket.logging_bucket[0].id
  target_prefix = "logs/"
}

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

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
