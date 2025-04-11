# External Secrets Operator Module
# This module deploys External Secrets Operator to the EKS cluster

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "0.9.9" # Specify a version for stability

  set {
    name  = "installCRDs"
    value = "true"
  }

  # Wait for External Secrets to be ready
  timeout = 1800
}

# Wait for External Secrets CRDs to be available
resource "time_sleep" "wait_for_crds" {
  depends_on      = [helm_release.external_secrets]
  create_duration = "60s"
}

# Create IAM role for External Secrets
resource "aws_iam_role" "external_secrets" {
  name = "${var.project_name}-${var.environment}-external-secrets"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.eks_oidc_provider}:sub" = "system:serviceaccount:external-secrets:external-secrets"
            "${var.eks_oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-external-secrets"
    Environment = var.environment
  }
}

# Create IAM policy for External Secrets
resource "aws_iam_policy" "external_secrets" {
  name        = "${var.project_name}-${var.environment}-external-secrets"
  description = "Policy for External Secrets Operator to access AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-external-secrets"
    Environment = var.environment
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

# Create Kubernetes service account for External Secrets
resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets-sa"
    namespace = "external-secrets"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
    }
  }

  depends_on = [helm_release.external_secrets]
}

# Create ClusterSecretStore for AWS Secrets Manager
resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = kubernetes_service_account.external_secrets.metadata[0].name
                namespace = kubernetes_service_account.external_secrets.metadata[0].namespace
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.external_secrets,
    time_sleep.wait_for_crds,
    kubernetes_service_account.external_secrets
  ]
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
