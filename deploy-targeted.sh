#!/bin/bash

# Set environment variables
export AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID .env | cut -d= -f2)
export AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY .env | cut -d= -f2)
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=575977136211
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev

# Set AWS profile to use the role
export AWS_PROFILE=infra-role

echo "Deploying infrastructure to AWS in stages..."
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
cd terraform

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -reconfigure -upgrade \
    -backend-config="bucket=fastapi-project-terraform-state-575977136211" \
    -backend-config="key=fastapi/infra/terraform.tfstate" \
    -backend-config="region=us-east-1" \
    -backend-config="dynamodb_table=terraform-state-lock-test"

# Stage 1: Deploy VPC
echo "Stage 1: Deploying VPC..."
terraform apply -target=module.vpc -auto-approve \
    -var="aws_region=us-east-1" \
    -var="environment=dev"

# Stage 2: Deploy EKS
echo "Stage 2: Deploying EKS..."
terraform apply -target=module.eks -auto-approve \
    -var="aws_region=us-east-1" \
    -var="environment=dev"

# Stage 3: Deploy ArgoCD
echo "Stage 3: Deploying ArgoCD..."
terraform apply -auto-approve \
    -var="aws_region=us-east-1" \
    -var="environment=dev"

echo "Infrastructure deployed successfully!"
