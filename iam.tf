variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  default     = "575977136211"  # Default value, can be overridden
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
  default     = "datascientest-fastAPI-project-group-25/fastAPI-project-infra"
}

variable "github_actions_role_name" {
  type        = string
  description = "Name of the IAM role for GitHub Actions"
  default     = "FastAPIProjectInfraRole"  # Match the role name used in the GitHub Actions workflow
}

# The OIDC provider ARN is hardcoded to avoid the need for iam:ListOpenIDConnectProviders permission
locals {
  github_oidc_provider_arn = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
}

# Reference the existing IAM role for GitHub Actions instead of creating it
data "aws_iam_role" "github_actions" {
  name = var.github_actions_role_name
}

# DynamoDB table resource is commented out due to SCP restrictions
# resource "aws_dynamodb_table" "terraform_lock" {
#   name         = "terraform-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
# 
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# Create policy for S3 access (for Terraform state)
resource "aws_iam_policy" "s3_policy" {
  name        = "S3TerraformStateAccess"
  description = "Policy for Terraform state access in S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-terraform-state-bucket-eu-west-2",
          "arn:aws:s3:::my-terraform-state-bucket-eu-west-2/*"
        ]
      },
    ]
  })
}

# DynamoDB policy is commented out due to SCP restrictions
# resource "aws_iam_policy" "dynamodb_policy" {
#   name        = "DynamoDBTerraformStateLock"
#   description = "Policy for Terraform state locking with DynamoDB"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "dynamodb:GetItem",
#           "dynamodb:PutItem",
#           "dynamodb:DeleteItem"
#         ]
#         Resource = "*" # aws_dynamodb_table.terraform_lock.arn
#       },
#     ]
#   })
# }

# Create IAM policy for necessary permissions
resource "aws_iam_policy" "iam_policy" {
  name        = "IAMPermissionsForTerraform"
  description = "Policy for IAM permissions needed by Terraform"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "iam:ListOpenIDConnectProviders",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider"
        ]
        Resource = "*"
      },
    ]
  })
}

# Attach policies to the GitHub Actions role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = data.aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "iam_policy_attachment" {
  role       = data.aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

# DynamoDB policy attachment is commented out due to SCP restrictions
# resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.dynamodb_policy.arn
# }