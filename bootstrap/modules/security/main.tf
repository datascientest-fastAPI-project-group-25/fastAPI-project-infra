terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# GitHub Actions OIDC Provider
# Only fetch OIDC provider in AWS environment
data "aws_iam_openid_connect_provider" "github_actions" {
  count = var.use_localstack ? 0 : 1
  url = "https://token.actions.githubusercontent.com"
}

locals {
  github_actions_oidc_arn = var.use_localstack ? "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com" : data.aws_iam_openid_connect_provider.github_actions[0].arn
}

# GitHub Actions Role for bootstrapping
resource "aws_iam_role" "github_actions_bootstrap_role" {
  count = var.use_localstack ? 0 : 1
  name = "GitHubActionsBootstrapRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.github_actions_oidc_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub": "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "GitHubActionsBootstrapRole"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

# GitHub Actions Policy
resource "aws_iam_role_policy" "github_actions_bootstrap_policy" {
  count = var.use_localstack ? 0 : 1
  name = "GitHubActionsBootstrapPolicy"
  role = aws_iam_role.github_actions_bootstrap_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:CreateBucket",
          "s3:PutBucketVersioning",
          "s3:PutBucketEncryption",
          "s3:PutBucketPolicy",
          "s3:PutBucketLifecycleConfiguration",
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "dynamodb:DeleteTable",
          "iam:PassRole",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRole",
          "sts:AssumeRole"
        ],
        Resource = var.resource_arns
      }
    ]
  })
}

# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  count = var.use_localstack ? 0 : 1
  name  = "lambda-execution-role"

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

# Lambda function for S3 notifications
resource "aws_lambda_function" "s3_event_lambda" {
  count         = var.use_localstack ? 0 : 1
  function_name = "s3-event-processor"
  role          = aws_iam_role.lambda_role[0].arn
  handler       = "notification_handler.lambda_handler"
  runtime       = "nodejs18.x"
  filename      = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
}

# Lambda permission for S3 bucket
resource "aws_lambda_permission" "allow_s3_event" {
  count         = var.use_localstack ? 0 : 1
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_lambda[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.state_bucket_arn
  source_account = var.aws_account_id
}

# S3 bucket notification configuration
resource "aws_s3_bucket_notification" "terraform_state_notifications" {
  count  = var.use_localstack ? 0 : 1
  bucket = var.state_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_event_lambda[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "terraform.tfstate"
  }
}