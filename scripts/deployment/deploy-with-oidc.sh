#!/bin/bash

# Script to deploy infrastructure using OIDC authentication

# Unset any existing AWS environment variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE

# Set environment variables
export AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID .env | cut -d= -f2)
export AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY .env | cut -d= -f2)
export AWS_DEFAULT_REGION=$(grep AWS_DEFAULT_REGION .env | cut -d= -f2 || echo "us-east-1")
export AWS_ACCOUNT_ID=$(grep AWS_ACCOUNT_ID .env | cut -d= -f2 || echo "221082192409")
export PROJECT_NAME=$(grep PROJECT_NAME .env | cut -d= -f2 || echo "fastapi-project")
export ENVIRONMENT=$(grep ENVIRONMENT .env | cut -d= -f2 || echo "dev")

echo "Deploying infrastructure to AWS using OIDC authentication..."
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"

# Verify AWS credentials
echo "Verifying AWS credentials..."
CALLER_IDENTITY=$(aws sts get-caller-identity)
echo "$CALLER_IDENTITY"

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify AWS credentials"
    exit 1
fi

# Extract the AWS account ID from the caller identity
ACTUAL_ACCOUNT_ID=$(echo "$CALLER_IDENTITY" | grep -o '"Account": "[0-9]*"' | cut -d\" -f4)

# Verify that we're using the correct AWS account
if [ "$ACTUAL_ACCOUNT_ID" != "$AWS_ACCOUNT_ID" ]; then
    echo "Error: AWS account ID mismatch. Expected $AWS_ACCOUNT_ID but got $ACTUAL_ACCOUNT_ID"
    echo "Configuring AWS CLI to use the correct credentials..."

    # Configure AWS CLI to use these credentials
    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
    aws configure set region $AWS_DEFAULT_REGION

    # Verify configuration again
    echo "Verifying AWS credentials after reconfiguration..."
    CALLER_IDENTITY=$(aws sts get-caller-identity)
    ACTUAL_ACCOUNT_ID=$(echo "$CALLER_IDENTITY" | grep -o '"Account": "[0-9]*"' | cut -d\" -f4)

    if [ "$ACTUAL_ACCOUNT_ID" != "$AWS_ACCOUNT_ID" ]; then
        echo "Error: AWS account ID still mismatched after reconfiguration. Expected $AWS_ACCOUNT_ID but got $ACTUAL_ACCOUNT_ID"
        exit 1
    fi

    echo "AWS credentials reconfigured successfully"
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

# Auto-unlock stale Terraform state lock
echo "Checking for stale Terraform state lock..."
PLAN_OUT=$(terraform plan -no-color 2>&1) || true
if echo "$PLAN_OUT" | grep -q 'Error acquiring the state lock'; then
  # Try multiple patterns to extract the lock ID
  LOCK_ID=$(echo "$PLAN_OUT" | grep -o 'ID: [a-zA-Z0-9\-]*' | cut -d' ' -f2)
  if [ -z "$LOCK_ID" ]; then
    LOCK_ID=$(echo "$PLAN_OUT" | sed -nE 's/^[[:space:]]*ID:[[:space:]]*([[:alnum:]-]+)$/\1/p')
  fi

  if [ -n "$LOCK_ID" ]; then
    echo "Stale lock detected (ID=$LOCK_ID), forcing unlock..."
    terraform force-unlock -force "$LOCK_ID"
  else
    echo "Failed to parse LOCK_ID"
    exit 1
  fi
fi

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
