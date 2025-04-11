# GitHub Container Registry Access Module
# This module sets up OIDC authentication with GitHub for pulling images from GitHub Container Registry

# Create IAM OIDC Provider for GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # GitHub's OIDC thumbprint - this is the certificate thumbprint for GitHub's OIDC provider
  # This should be updated if GitHub rotates their certificates
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  
  tags = {
    Name        = "github-oidc-provider"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Create IAM Role for GitHub OIDC
resource "aws_iam_role" "github_actions" {
  name = "github-actions-${var.environment}"
  description = "IAM role for GitHub Actions OIDC authentication for ${var.environment} environment"

  # This trust policy allows GitHub Actions to assume this role using OIDC
  # It restricts access to only repositories in the specified GitHub organization
  # and only for specific environments or branches if needed
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
            # This condition restricts access to repositories in the specified GitHub organization
            # Format: repo:OWNER/REPO:ref:REF or repo:OWNER/REPO:environment:ENVIRONMENT
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/*:*"
          }
        }
      }
    ]
  })

  # Maximum session duration for the role (1 hour)
  max_session_duration = 3600

  tags = {
    Name        = "github-actions-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
    Purpose     = "GitHub OIDC Authentication"
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
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "arn:aws:ecr:*:*:repository/*${var.environment}*"
      }
    ]
  })

  tags = {
    Name        = "github-ecr-policy-${var.environment}"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "github_ecr_attachment" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_ecr_policy.arn
}

# Create Kubernetes service account for pulling images
# This service account is used by pods to authenticate with ECR
resource "kubernetes_service_account" "ghcr_service_account" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-service-account"
    namespace = each.value
    annotations = {
      # This annotation links the service account to the IAM role
      # It enables IAM Roles for Service Accounts (IRSA) in EKS
      "eks.amazonaws.com/role-arn" = aws_iam_role.github_actions.arn
    }
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

# Create Kubernetes role for OIDC authentication
# This role defines the permissions for the service account
resource "kubernetes_role" "ghcr_role" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-role"
    namespace = each.value
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }

  # These permissions allow the service account to get information about pods and service accounts
  # This is needed for the GitHub Actions workflow to interact with the cluster
  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create Kubernetes role binding for OIDC authentication
# This role binding associates the role with the service account
resource "kubernetes_role_binding" "ghcr_role_binding" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "ghcr-role-binding"
    namespace = each.value
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }

  # Reference to the role we created above
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ghcr_role[each.value].metadata[0].name
  }

  # Reference to the service account that will use this role
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ghcr_service_account[each.value].metadata[0].name
    namespace = each.value
  }
}
