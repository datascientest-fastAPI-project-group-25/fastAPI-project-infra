#!/bin/bash

# Script to deploy infrastructure using OIDC authentication

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1
# Get AWS account ID from environment or .env file
if [ -z "$AWS_ACCOUNT_ID" ]; then
  export AWS_ACCOUNT_ID=$(grep AWS_ACCOUNT_ID .env | cut -d= -f2 || echo "221082192409")
fi
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=${ENVIRONMENT:-dev}

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

# Check if backend.config exists, if not create it
if [ ! -f "backend.config" ]; then
  echo "Creating backend.config..."
  cat > backend.config << EOF
bucket         = "fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
key            = "fastapi/infra/${ENVIRONMENT}/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-lock-${ENVIRONMENT}"
encrypt        = true
EOF
fi

# Update backend.tf to use S3
echo "Updating backend configuration to use S3..."
cat > backend.tf << EOF
# Terraform backend and provider configuration
terraform {
  # Using S3 backend for development
  backend "s3" {}
  # The actual backend configuration is provided during terraform init
  # via the -backend-config parameters

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
terraform init -reconfigure -backend-config=backend.config

# Check if we need to modify providers.tf to handle EKS cluster creation
if grep -q "data.aws_eks_cluster.cluster" providers.tf; then
  echo "Modifying providers.tf to handle initial EKS cluster creation..."
  # Create a backup of the original file
  cp providers.tf providers.tf.bak

  # Modify the providers.tf file to use placeholder values for Kubernetes and Helm providers
  # This allows the EKS cluster to be created first
  sed -i 's/host                   = data.aws_eks_cluster.cluster.endpoint/host                   = "https:\/\/localhost:8080" # Placeholder/g' providers.tf
  sed -i 's/cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority\[0\].data)/cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJd01ETXhOekl3TURjeU5Gb1hEVE13TURNeE5USXdNRGN5TkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTTZWCjVUaG5ERHlreVZQQlJlZVBYaUhqUW1GUXJkVEV0ZUFiQmlWTGtPUVhyT3RMUk1jUmg3N0FuZVNFMEVlTUE5YksKRkxnOHVNK1U4N3lOQk9VU2JwZlZkbFBuczM0REZEZWJlWXlPVnRlWVJVNUt1cDdQYWVUZHJiQTQwbnlPTmtVUQpDTWVzNGJiUjJxRk9wUW5oZGVsODJIaVFvMUhNQ1JrVzFSYWpkSXhNb3ZNUCtQK0pOK1RFaHJTQXc3alJjRDkrCnJqcUNIL0ZsYWJSMDFBYmw0NmlHQXZvdWMrOVJUbkRNTXRYZUNMWlhKTlZJT0VPWnBqSzFNQUJGMUlnQjBoTncKZFJwL0FrTXQ3ZkpKMnJrRDJEclF0QVdialZNTXc5Y3NpSEROTWZXSzJkbkVZWHFFOHRWL1dxbDFULzZwZDlrVgpZdDFyUTdtNDZEc0RzZHNDQXdFQUFhTkNNRUF3RGdZRFZSMFBBUUgvQkFRREFnS2tNQThHQTFVZEV3RUIvd1FGCk1BTUJBZjh3SFFZRFZSME9CQllFRkFKZUFGUEVrY1hidDIvRG9Gd1pBVGFDQjVBSU1BMEdDU3FHU0liM0RRRUIKQ3dVQUE0SUJBUUJYTnorMEJ1YXZKWUxsZUJ4eHdiWk1rVjBFMHl0VXpITVkxUUJGRUJFTmJJUE9QYjZ3OUpkVApNQTlYTVFzM0JiRFNGc2hNdkVTUXZYc0VSTnVxelFnZTQ0ODR1WTNBL0RMRVhtZ2tJQzRIRlBxbngwRHJDTatCCnFhVDJ4bFRBOCtQWXRsZHlYRVZ3ZGthOTVnY3ZTMjJzYmVGcHNoZW5jRFpEbTFMcUxVbnIxN2ZyVGVTS1JGaHMKWkpZNDVDWGpuNkJHOFR0NUoyVG1XRmY1V0JFaEFPazdxdU1QbEFXNnpwZjZJdGZuQVpXUHRvT1d0K2xpTlZUNQpJZlZnWjJvWDJERXhPd1FYdlNyTVpjQ1QrSjdoMHVQcWVrQlRtdlpqVVdIY1VLbVZDOUlnWGNGNnczNHl0V3JoCmJIYnJSTU5RNWNFRnJXZ0FsUzRzNGEwWQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==") # Placeholder/g' providers.tf
  sed -i 's/token                  = data.aws_eks_cluster_auth.cluster.token/token                  = "placeholder-token"/g' providers.tf

  # Add insecure = true to the kubernetes provider
  sed -i '/provider "kubernetes" {/a\  insecure               = true # Allow insecure connections initially' providers.tf

  # Add insecure = true to the helm provider
  sed -i '/kubernetes {/a\    insecure               = true # Allow insecure connections initially' providers.tf
fi

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
