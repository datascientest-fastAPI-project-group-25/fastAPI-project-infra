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

echo "Applying bootstrap resources to AWS..."
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"

# Verify AWS credentials
echo "Verifying AWS credentials..."
aws sts get-caller-identity

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify AWS credentials"
    exit 1
fi

# Change to the bootstrap/environments/aws directory
cd bootstrap/environments/aws

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -reconfigure \
    -backend-config=backend.hcl \
    -backend-config="bucket=fastapi-project-terraform-state-${AWS_ACCOUNT_ID}" \
    -backend-config="dynamodb_table=terraform-state-lock-test"

# Apply Terraform configuration
echo "Applying Terraform configuration..."
terraform apply -auto-approve \
    -var="aws_account_id=${AWS_ACCOUNT_ID}" \
    -var="aws_region=${AWS_DEFAULT_REGION}" \
    -var="environment=${ENVIRONMENT}" \
    -var="project_name=${PROJECT_NAME}" \
    -var="dynamodb_table_name=terraform-state-lock-test"

echo "Bootstrap resources applied successfully!"
