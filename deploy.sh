#!/bin/bash

# Set environment variables
export AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID .env | cut -d= -f2)
export AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY .env | cut -d= -f2)
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-221082192409}
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
    -var="aws_region=us-east-1" \
    -var="environment=dev" \
    -out=tfplan

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
