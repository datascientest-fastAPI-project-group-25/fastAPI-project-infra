# External Secrets Operator Module
# This module installs and configures External Secrets Operator in the EKS cluster

# Create namespace for External Secrets Operator
resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

# Create IAM role for External Secrets Operator
resource "aws_iam_role" "external_secrets" {
  name = "external-secrets-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.eks_oidc_provider}:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "${var.eks_oidc_provider}:sub" = "system:serviceaccount:external-secrets:external-secrets-*"
          }
        }
      }
    ]
  })
  
  tags = {
    Name        = "external-secrets-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

# Create IAM policy for External Secrets Operator to access Secrets Manager
resource "aws_iam_policy" "external_secrets" {
  name        = "external-secrets-policy-${var.environment}"
  description = "Policy for External Secrets Operator to access Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:*:secret:${var.environment}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name        = "external-secrets-policy-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

# Install External Secrets Operator using Helm
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  version    = "0.9.9"
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
  }
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  values = [
    <<-EOT
    podLabels:
      environment: ${var.environment}
    EOT
  ]
  
  depends_on = [
    kubernetes_namespace.external_secrets,
    aws_iam_role_policy_attachment.external_secrets
  ]
}
