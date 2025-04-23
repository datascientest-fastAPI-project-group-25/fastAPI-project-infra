#!/bin/bash

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

# Set AWS profile to use the role
export AWS_PROFILE=infra-role

echo "Deploying infrastructure to AWS..."
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
    -backend-config="bucket=fastapi-project-terraform-state-${AWS_ACCOUNT_ID}" \
    -backend-config="key=fastapi/infra/terraform.tfstate" \
    -backend-config="region=us-east-1" \
    -backend-config="dynamodb_table=terraform-state-lock-test"

# Deploy VPC
echo "Deploying VPC..."
terraform apply -target=module.vpc -auto-approve \
    -var="aws_region=us-east-1" \
    -var="environment=dev"

# Deploy Security Groups
echo "Deploying Security Groups..."
terraform apply -target=module.security -auto-approve \
    -var="aws_region=us-east-1" \
    -var="environment=dev"

# Deploy EKS
echo "Deploying EKS..."
terraform apply -target=module.eks -auto-approve \
    -var="aws_region=us-east-1" \
    -var="environment=dev"

# Deploy ArgoCD
echo "Deploying ArgoCD..."
terraform apply -auto-approve \
    -var="aws_region=us-east-1" \
    -var="environment=dev"

echo "Infrastructure deployed successfully!"
