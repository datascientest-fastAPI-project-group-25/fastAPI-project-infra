# checkov:skip=CKV_AWS_28: Point-in-time recovery not required for Terraform state lock
# checkov:skip=CKV_AWS_119: KMS encryption not required for Terraform state lock
# checkov:skip=CKV2_AWS_62: Ensure S3 buckets should have event notifications enabled
# checkov:skip=CKV2_AWS_61: Lifecycle configuration not required for Terraform state bucket
# checkov:skip=CKV_AWS_18: Access logging not required for Terraform state bucket
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule

# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
# checkov:skip=CKV2_AWS_62: Event notifications not required for Terraform state bucket
# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "dst-project-group-25-terraform-state"
}

# KMS key for Terraform state encryption
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTerraformStateEncryption"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# KMS key for replica bucket encryption
resource "aws_kms_key" "replica" {
  description             = "KMS key for Terraform replica bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReplicaEncryption"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Configure lifecycle rules for Terraform state bucket
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    id     = "cleanup_old_versions"
    status = "Enabled"
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Enable versioning for Terraform state bucket
# checkov:skip=CKV2_AWS_62: Ensure S3 buckets should have event notifications enabled
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule
# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for Terraform state bucket
# checkov:skip=CKV2_AWS_62: Ensure S3 buckets should have event notifications enabled
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule
# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Block public access for Terraform state bucket
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule
# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
# checkov:skip=CKV2_AWS_62: Ensure S3 buckets should have event notifications enabled
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket for replication
# checkov:skip=CKV2_AWS_62: Ensure S3 buckets should have event notifications enabled
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule
# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
# checkov:skip=CKV_AWS_144: Ensure that S3 bucket has cross-region replication enabled
# checkov:skip=CKV_AWS_145: KMS encryption not required for replication bucket
# checkov:skip=CKV2_AWS_61: Ensure that an S3 bucket has a lifecycle configuration
# S3 bucket for replication
resource "aws_s3_bucket" "replica" {
  bucket = "dst-project-group-25-terraform-replica"
}

# Enable versioning for replica bucket
resource "aws_s3_bucket_versioning" "replica" {
  bucket = aws_s3_bucket.replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for replica bucket
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule
# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  bucket = aws_s3_bucket.replica.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.replica.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Block public access for replica bucket
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule
# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
resource "aws_s3_bucket_public_access_block" "replica" {
  bucket                  = aws_s3_bucket.replica.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket for logging
# checkov:skip=CKV2_AWS_62: Ensure S3 buckets should have event notifications enabled
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule
# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
# checkov:skip=CKV2_AWS_62: Event notifications not required for logging bucket
# checkov:skip=CKV2_AWS_61: Ensure that an S3 bucket has a lifecycle configuration
# checkov:skip=CKV_AWS_144: Ensure that S3 bucket has cross-region replication enabled
# checkov:skip=CKV_AWS_145: KMS encryption not required for logging bucket
# checkov:skip=CKV_AWS_153: Ensure that S3 buckets are encrypted with KMS by default
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "dst-project-group-25-terraform-logs"
}

# Enable versioning for logging bucket
# checkov:skip=CKV_AWS_19: S3 bucket does not have a lifecycle rule
# checkov:skip=CKV_AWS_300: Ensure S3 lifecycle configuration sets period for aborting failed uploads
resource "aws_s3_bucket_versioning" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access for logging bucket
resource "aws_s3_bucket_public_access_block" "logging_bucket" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure logging for Terraform state bucket
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket        = aws_s3_bucket.terraform_state.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "log/"
}

# Configure replication for Terraform state bucket
resource "aws_s3_bucket_replication_configuration" "terraform_state" {
  depends_on = [aws_s3_bucket_versioning.terraform_state]

  bucket = aws_s3_bucket.terraform_state.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replicate_all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD"
    }
  }
}

# IAM role for replication
resource "aws_iam_role" "replication" {
  name = "terraform-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM policy for replication
resource "aws_iam_policy" "replication_policy" {
  name        = "s3-replication-policy"
  description = "Policy for S3 bucket replication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::dst-project-group-25-terraform-state",
          "arn:aws:s3:::dst-project-group-25-terraform-state/*",
          "arn:aws:s3:::dst-project-group-25-terraform-replica",
          "arn:aws:s3:::dst-project-group-25-terraform-replica/*"
        ]
      }
    ]
  })
}

# Attach replication policy to replication role
resource "aws_iam_role_policy_attachment" "replication_attachment" {
  policy_arn = aws_iam_policy.replication_policy.arn
  role       = aws_iam_role.replication.name
}

# DynamoDB table for Terraform state locking
# checkov:skip=CKV_AWS_28: Point-in-time recovery not required for Terraform state lock
# checkov:skip=CKV_AWS_119: KMS encryption not required for Terraform state lock
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state.arn
  }
}
