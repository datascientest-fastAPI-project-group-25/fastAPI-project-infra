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

# Use local variable for the role name instead of data source to avoid needing iam:GetRole permission
locals {
  github_actions_role_name = var.github_actions_role_name
}

 #DynamoDB table resource is commented out due to SCP restrictions
 #resource "aws_dynamodb_table" "terraform_lock" {
  # name         = "terraform-lock"
   #billing_mode = "PAY_PER_REQUEST"
   #hash_key     = "LockID"
 
   #attribute {
    # name = "LockID"
     #type = "S"
   #}
 #}

resource "aws_iam_role_policy" "github_actions_policy" {
  name = "GitHubActionsPolicy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:UpdateRole",
          "iam:UpdateRoleDescription"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "github_actions_role" {
  name = "FastAPIProjectInfraRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "github.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })
}

# Define S3 policy document for reference
data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::my-terraform-state-bucket-eu-west-2",
      "arn:aws:s3:::my-terraform-state-bucket-eu-west-2/*"
    ]
  }
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

# Define IAM policy document for reference
data "aws_iam_policy_document" "iam_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "iam:ListOpenIDConnectProviders",
      "iam:GetOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies"
    ]
    resources = ["*"]
  }
}

# Add inline policies to the GitHub Actions role
resource "aws_iam_role_policy" "s3_inline_policy" {
  name   = "S3TerraformStateAccess"
  role   = local.github_actions_role_name
  policy = data.aws_iam_policy_document.s3_policy_doc.json
}

resource "aws_iam_role_policy" "iam_inline_policy" {
  name   = "IAMPermissionsForTerraform"
  role   = local.github_actions_role_name
  policy = data.aws_iam_policy_document.iam_policy_doc.json
}

# DynamoDB policy attachment is commented out due to SCP restrictions
# resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.dynamodb_policy.arn
# }