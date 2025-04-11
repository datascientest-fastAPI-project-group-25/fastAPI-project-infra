# GitHub Container Registry Access Module
# This module sets up OIDC authentication with GitHub for pulling images from GitHub Container Registry

# Create IAM OIDC Provider for GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Create IAM Role for GitHub OIDC
resource "aws_iam_role" "github_actions" {
  name = "github-actions-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/*:*"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# Create IAM policy for ECR access
resource "aws_iam_policy" "github_ecr_policy" {
  name        = "github-ecr-policy-${var.environment}"
  description = "Policy for GitHub Actions to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "github_ecr_attachment" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_ecr_policy.arn
}

# Create Kubernetes service account for pulling images
resource "kubernetes_service_account" "ghcr_service_account" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-service-account"
    namespace = each.value
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.github_actions.arn
    }
  }
}

# Create Kubernetes role for OIDC authentication
resource "kubernetes_role" "ghcr_role" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-role"
    namespace = each.value
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create Kubernetes role binding for OIDC authentication
resource "kubernetes_role_binding" "ghcr_role_binding" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-role-binding"
    namespace = each.value
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ghcr_role[each.value].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ghcr_service_account[each.value].metadata[0].name
    namespace = each.value
  }
}
