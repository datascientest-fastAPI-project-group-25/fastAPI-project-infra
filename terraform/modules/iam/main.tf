# IAM Roles
resource "aws_iam_role" "github_actions" {
  name = var.github_actions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = var.github_actions_oidc_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/*"
          }
        }
      }
    ]
  })

  # Adding tags to the role
  tags = {
    Name        = var.github_actions_role_name
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "lambda-execution-role"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

# Policy Documents
data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::fastapi-project-terraform-state-${var.aws_account_id}",
      "arn:aws:s3:::fastapi-project-terraform-state-${var.aws_account_id}/*"
    ]
  }
}

data "aws_iam_policy_document" "dynamodb_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.dynamodb_table_name}"]
  }
}

data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:InvokeFunction",
      "lambda:GetFunction",
      "lambda:DeleteFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:s3-event-processor"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::fastapi-project-terraform-state-${var.aws_account_id}",
      "arn:aws:s3:::fastapi-project-terraform-state-${var.aws_account_id}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.dynamodb_table_name}"
    ]
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:InvokeFunction",
      "lambda:GetFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:s3-event-processor"
    ]
  }
}

# Attach policies to roles
resource "aws_iam_role_policy" "github_actions_policy" {
  name = "github-actions-policy"
  role = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.github_actions_policy.json
}

resource "aws_iam_role_policy" "s3_inline_policy" {
  name   = "S3TerraformStateAccess"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.s3_policy_doc.json
}

resource "aws_iam_role_policy" "dynamodb_inline_policy" {
  name   = "DynamoDBTerraformLock"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.dynamodb_policy_doc.json
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-execution-policy"
  role = aws_iam_role.lambda_role.name
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "fastapi-project-terraform-state-${var.aws_account_id}"

  # Tag the bucket with the same tags
  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

# DynamoDB table for locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}