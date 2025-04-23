#!/bin/bash

# Script to deploy infrastructure using OIDC authentication

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1

# Check if AWS_ACCOUNT_ID is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: AWS_ACCOUNT_ID environment variable is not set."
    echo "Please set it before running this script:"
    echo "export AWS_ACCOUNT_ID=your_aws_account_id"
    exit 1
fi

# Check if AWS credentials are available (from environment or IAM role)
aws sts get-caller-identity &>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: AWS credentials are not available or are invalid."
    echo "Please configure AWS credentials using one of these methods:"
    echo "1. Set up AWS CLI with 'aws configure'"
    echo "2. Use IAM roles for EC2 instances or EKS clusters"
    echo "3. Use OIDC authentication for GitHub Actions"
    exit 1
fi
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev

echo "Deploying infrastructure to AWS using OIDC authentication..."
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"

# Verify AWS credentials
echo "Verifying AWS credentials..."
aws sts get-caller-identity

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify AWS credentials"
    exit 1
fi

# Change to the terraform directory
cd terraform/environments/clean-deploy/development

# Initialize Terraform with local backend first
echo "Initializing Terraform with local backend..."
terraform init

# Update backend.tf to use S3
echo "Updating backend configuration to use S3..."
cat > backend.tf << EOF
# Terraform backend and provider configuration
terraform {
  # Using S3 backend for development
  backend "s3" {
    bucket         = "fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
    key            = "fastapi/infra/development/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-dev"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}
EOF

# Migrate state to S3
echo "Migrating state to S3..."
terraform init -migrate-state -force-copy

# Deploy IAM resources first (including OIDC provider)
echo "Deploying IAM resources (including OIDC provider)..."
terraform apply -target=module.iam -auto-approve

# Deploy VPC
echo "Deploying VPC..."
terraform apply -target=module.vpc -auto-approve

# Deploy Security Groups
echo "Deploying Security Groups..."
terraform apply -target=module.security -auto-approve

# Deploy EKS
echo "Deploying EKS..."
terraform apply -target=module.eks -auto-approve

# Deploy Kubernetes resources
echo "Deploying Kubernetes resources..."
terraform apply -target=module.k8s_resources -auto-approve

# Deploy ArgoCD
echo "Deploying ArgoCD..."
terraform apply -target=module.argocd -auto-approve

# Deploy External Secrets Operator
echo "Deploying External Secrets Operator..."
terraform apply -target=module.external_secrets -auto-approve

# Deploy GHCR Access
echo "Deploying GHCR Access..."
terraform apply -target=module.ghcr_access -auto-approve

echo "Infrastructure deployed successfully!"
