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

# Use existing OIDC Provider for GitHub Actions
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Create the IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" = ["repo:${var.github_repo}:ref:refs/heads/main"]
          }
        }
      }
    ]
  })
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

# Attach policies to the GitHub Actions role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# DynamoDB policy attachment is commented out due to SCP restrictions
# resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.dynamodb_policy.arn
# }