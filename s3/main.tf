# Main bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
}

# Create logging bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.bucket_name}-logs"
}

# Create replica bucket in different region
resource "aws_s3_bucket" "replica" {
  provider = aws.replica
  bucket   = "${var.bucket_name}-replica"
}

# Enable versioning for main bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable versioning for logging bucket
resource "aws_s3_bucket_versioning" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable versioning for replica bucket
resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Notification for main bucket
resource "aws_s3_bucket_notification" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  topic {
    topic_arn = aws_sns_topic.bucket_updates.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

# Notification for logging bucket
resource "aws_s3_bucket_notification" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id

  topic {
    topic_arn = aws_sns_topic.bucket_updates.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

# Notification for replica bucket
resource "aws_s3_bucket_notification" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  topic {
    topic_arn = aws_sns_topic.bucket_updates.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}



# Enable encryption for main bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable encryption for replica bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.replica.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable encryption for logging bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Block public access for logging bucket
resource "aws_s3_bucket_public_access_block" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Block public access for replica bucket
resource "aws_s3_bucket_public_access_block" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enforce bucket policy to block public access
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "DenyPublicAccess",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowGitHubActions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:role/${var.github_actions_role_name}"
        },
        Action = "s3:*",
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:PrincipalArn" = "arn:aws:iam::${var.aws_account_id}:role/${var.github_actions_role_name}"
          }
        }
      }
    ]
  })
}

# Create KMS key for S3
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Encryption"
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

# Enable logging
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket        = aws_s3_bucket.terraform_state.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "log/"
}

# SNS Topic for bucket notifications
resource "aws_sns_topic" "bucket_updates" {
  name              = "${var.bucket_name}-updates"
  kms_master_key_id = aws_kms_key.s3_key.arn
}

# Enable replication
resource "aws_s3_bucket_replication_configuration" "terraform_state" {
  depends_on = [aws_s3_bucket_versioning.terraform_state]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "replicate_all"
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.replica.arn
      encryption_configuration {
        replica_kms_key_id = aws_kms_key.replica.arn
      }
    }
  }
}

# IAM role for replication
resource "aws_iam_role" "replication" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          },
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.terraform_state.arn
          }
        }
      }
    ]
  })
}

# IAM policy for replication
resource "aws_iam_policy" "replication" {
  name = "s3-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.replica.arn}/*"
      },
      {
        Action = [
          "kms:Decrypt"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.s3_key.arn
      },
      {
        Action = [
          "kms:Encrypt"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.replica.arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

# Lifecycle rules
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

    # Add abort incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# KMS key for replica bucket
resource "aws_kms_key" "replica" {
  provider                = aws.replica
  description             = "KMS key for S3 replica bucket encryption"
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

resource "aws_s3_bucket_logging" "replica" {
  provider      = aws.replica
  bucket        = aws_s3_bucket.replica.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    id     = "log-lifecycle"
    status = "Enabled"

    expiration {
      days = 365
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_iam_role" "replication" {
  name = "terraform-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_s3_bucket" "replica" {
  bucket = "dst-project-group-25-terraform-replica"
}

resource "aws_s3_bucket_lifecycle_configuration" "replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica.id

  rule {
    id     = "replica-lifecycle"
    status = "Enabled"

    expiration {
      days = 365
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "logging_bucket" {
  depends_on = [aws_s3_bucket_versioning.logging_bucket]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    id     = "replicate_logs"
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.replica.arn
      encryption_configuration {
        replica_kms_key_id = aws_kms_key.replica.arn
      }
    }
  }
}
