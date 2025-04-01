terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Logging bucket
resource "aws_s3_bucket" "logging_bucket" {
  count  = var.use_localstack ? 0 : 1
  bucket = var.logs_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for the logging bucket
resource "aws_s3_bucket_versioning" "logging_bucket" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.logging_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for the logging bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logging_bucket" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.logging_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket logging configuration
resource "aws_s3_bucket_logging" "logging_bucket_logging" {
  count  = var.use_localstack ? 0 : 1
  bucket = aws_s3_bucket.logging_bucket[0].id
  target_bucket = aws_s3_bucket.logging_bucket[0].id
  target_prefix = "logs/"
}

# Lifecycle configuration for logs
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

# Configure logging for the state bucket if provided
resource "aws_s3_bucket_logging" "state_bucket_logging" {
  count = var.use_localstack || var.state_bucket_id == null ? 0 : 1
  bucket = var.state_bucket_id
  target_bucket = aws_s3_bucket.logging_bucket[0].id
  target_prefix = "state-bucket-logs/"
}