# Terraform configuration to add EKS permissions to the FastAPIProjectInfraRole

provider "aws" {
  region = "us-east-1"
}

# Create a policy for EKS administration
resource "aws_iam_policy" "eks_admin_policy" {
  name        = "EKSAdminPolicy"
  description = "Policy for EKS cluster administration"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the existing role
resource "aws_iam_role_policy_attachment" "eks_admin_attachment" {
  role       = "FastAPIProjectInfraRole"
  policy_arn = aws_iam_policy.eks_admin_policy.arn
}
