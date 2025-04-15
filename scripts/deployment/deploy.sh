#!/bin/bash

# Script to deploy infrastructure using Terraform
#
# Usage:
#   ./deploy.sh                  # Deploy all infrastructure
#   ./deploy.sh vpc             # Deploy only the VPC module
#   ./deploy.sh eks             # Deploy only the EKS module
#   ./deploy.sh security        # Deploy only the security module
#   ./deploy.sh argo            # Deploy only the ArgoCD module

# Check if .env file exists and load environment variables
if [ -f ".env" ]; then
    export AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID .env | cut -d= -f2)
    export AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY .env | cut -d= -f2)
fi

# Set default environment variables if not already set
: ${AWS_DEFAULT_REGION:="us-east-1"}
: ${PROJECT_NAME:="fastapi-project"}
: ${ENVIRONMENT:="dev"}

# Get AWS account ID if not set
if [ -z "$AWS_ACCOUNT_ID" ]; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
fi

# Set AWS profile if specified
if [ ! -z "$AWS_PROFILE" ]; then
    echo "Using AWS Profile: $AWS_PROFILE"
fi

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
    -backend-config="bucket=${PROJECT_NAME}-terraform-state-${AWS_ACCOUNT_ID}" \
    -backend-config="key=${PROJECT_NAME}/infra/terraform.tfstate" \
    -backend-config="region=${AWS_DEFAULT_REGION}" \
    -backend-config="dynamodb_table=terraform-state-lock-${ENVIRONMENT}"

# Validate Terraform configuration
echo "Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
    echo "Error: Terraform validation failed"
    exit 1
fi

# Plan Terraform changes
echo "Planning Terraform changes..."
terraform plan \
    -var="aws_region=${AWS_DEFAULT_REGION}" \
    -var="environment=${ENVIRONMENT}" \
    -out=tfplan

# Check if a specific module was specified
if [ ! -z "$1" ]; then
    MODULE=$1
    echo "Deploying specific module: $MODULE"

    # Plan Terraform changes for the specific module
    echo "Planning Terraform changes for module $MODULE..."
    terraform plan \
        -var="aws_region=${AWS_DEFAULT_REGION}" \
        -var="environment=${ENVIRONMENT}" \
        -target=module.$MODULE \
        -out=tfplan

    # Ask for confirmation
    read -p "Do you want to apply these changes to module $MODULE? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Apply Terraform changes
        echo "Applying Terraform changes to module $MODULE..."
        terraform apply tfplan

        echo "Module $MODULE deployed successfully!"
    else
        echo "Deployment cancelled."
    fi
else
    # Ask for confirmation
    read -p "Do you want to apply these changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Apply Terraform changes
        echo "Applying Terraform changes..."
        terraform apply tfplan

        echo "Infrastructure deployed successfully!"
    else
        echo "Deployment cancelled."
    fi
fi
