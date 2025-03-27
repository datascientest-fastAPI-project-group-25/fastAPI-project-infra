# GitHub Actions OIDC Provider
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# IAM Role for GitHub Actions OIDC
resource "aws_iam_role" "github_actions" {
  name = var.github_actions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github_actions.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub" : "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

# Policy Document for S3 Terraform Backend Access
data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::fastapi-project-terraform-state-${var.aws_account_id}",
      "arn:aws:s3:::fastapi-project-terraform-state-${var.aws_account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${var.aws_account_id}:role/${var.github_actions_role_name}"
      ]
    }
  }
}

# Policy Document for DynamoDB State Locking
data "aws_iam_policy_document" "dynamodb_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/terraform-lock"]
  }
}

# IAM Role Policies s3
resource "aws_iam_role_policy" "s3_inline_policy" {
  name   = "S3TerraformStateAccess"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.s3_policy_doc.json
}

# IAM Role Policies dynamodb
resource "aws_iam_role_policy" "dynamodb_inline_policy" {
  name   = "DynamoDBTerraformLock"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.dynamodb_policy_doc.json
}
