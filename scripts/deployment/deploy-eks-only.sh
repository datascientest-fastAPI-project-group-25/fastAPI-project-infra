#!/bin/bash

# Script to deploy only the EKS cluster without IAM resources
# This script is designed to work around permission issues

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=575977136211
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev2

# Check if AWS credentials are configured
echo "Deploying EKS cluster to AWS..."
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"
echo "Verifying AWS credentials..."
aws sts get-caller-identity

# Navigate to the development environment directory
cd terraform/environments/clean-deploy/development

# Update environment variable in main.tf
echo "Updating environment in main.tf..."
sed -i 's/environment  = "dev"/environment  = "dev2"/g' main.tf

# Initialize Terraform with local backend
echo "Initializing Terraform with local backend..."
terraform init

# Update backend.tf to use local backend
echo "Updating backend configuration to use local backend..."
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

# Reconfigure backend to use local
echo "Reconfiguring backend to use local..."
terraform init -reconfigure

# Deploy VPC
echo "Deploying VPC..."
terraform apply -target=module.vpc -auto-approve

# Deploy Security Groups
echo "Deploying Security Groups..."
terraform apply -target=module.security -auto-approve

# Deploy EKS
echo "Deploying EKS..."
terraform apply -target=module.eks -auto-approve

echo "EKS cluster deployment completed!"
