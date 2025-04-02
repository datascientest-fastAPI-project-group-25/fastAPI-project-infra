terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
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

# Create S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  count  = var.use_localstack ? 0 : 1
  bucket = var.s3_bucket_name

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

# Enable encryption for the state bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}