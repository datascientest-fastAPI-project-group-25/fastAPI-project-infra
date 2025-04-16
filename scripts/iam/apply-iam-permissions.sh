#!/bin/bash

# Script to apply IAM permissions for infrastructure deployment
# This script uses the IAM module to create the necessary policies
# and attaches them to the current user

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=575977136211
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev

# Check if AWS credentials are configured
echo "Applying IAM permissions for infrastructure deployment..."
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"
echo "Verifying AWS credentials..."
aws sts get-caller-identity

# Get the current user's ARN and username
USER_ARN=$(aws sts get-caller-identity --query "Arn" --output text)
USERNAME=$(echo $USER_ARN | cut -d'/' -f2)
echo "Current user: $USERNAME"

# Navigate to the development environment directory
cd terraform/environments/clean-deploy/development

# Initialize Terraform with local backend
echo "Initializing Terraform with local backend..."
cat > backend.tf << EOF
# Terraform backend and provider configuration
terraform {
  # Using local backend for development
  backend "local" {
    path = "terraform.tfstate"
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

terraform init

# Deploy only the IAM module
echo "Deploying IAM module to create policies..."
terraform apply -target=module.iam -auto-approve

# Get the policy ARNs
DYNAMODB_POLICY_ARN=$(terraform output -raw module.iam.dynamodb_state_lock_access_policy_arn)
INFRA_POLICY_ARN=$(terraform output -raw module.iam.infrastructure_deployment_policy_arn)

echo "DynamoDB Policy ARN: $DYNAMODB_POLICY_ARN"
echo "Infrastructure Deployment Policy ARN: $INFRA_POLICY_ARN"

# Attach policies to the user
echo "Attaching policies to user $USERNAME..."
aws iam attach-user-policy --user-name $USERNAME --policy-arn $DYNAMODB_POLICY_ARN
aws iam attach-user-policy --user-name $USERNAME --policy-arn $INFRA_POLICY_ARN

echo "IAM permissions applied successfully!"
echo "Now you can run the deployment script to create the cluster."
