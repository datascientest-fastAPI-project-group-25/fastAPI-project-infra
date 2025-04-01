#!/bin/bash

# Source environment loading script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../scripts/load-env.sh"

# Verify AWS credentials
echo "Verifying AWS credentials..."
aws sts get-caller-identity

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify AWS credentials"
    exit 1
fi

# Get AWS Account ID if not set
if [ -z "$AWS_ACCOUNT_ID" ]; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
    echo "AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID" >> ../../.env.bootstrap
fi

echo "Using AWS Account: $AWS_ACCOUNT_ID"

# Temporarily rename files to use local state
echo "Setting up local state configuration..."
mv main.tf main.tf.bak
mv main-local.tf main.tf

# Initialize Terraform with local state
echo "Initializing Terraform with local state..."
terraform init -reconfigure

# Plan changes
echo "Planning changes..."
terraform plan \
    -var="aws_account_id=${AWS_ACCOUNT_ID}" \
    -var="aws_region=eu-west-2" \
    -var="environment=${ENVIRONMENT}" \
    -var="project_name=${PROJECT_NAME}"

# Ask for confirmation
read -p "Do you want to apply these changes? (yes/no) " answer
if [ "$answer" != "yes" ]; then
    echo "Aborting..."
    exit 0
fi

# Apply changes
echo "Applying changes..."
terraform apply -auto-approve \
    -var="aws_account_id=${AWS_ACCOUNT_ID}" \
    -var="aws_region=eu-west-2" \
    -var="environment=${ENVIRONMENT}" \
    -var="project_name=${PROJECT_NAME}"

# Test the setup
echo "Testing the setup..."
echo "1. Verifying S3 buckets..."
aws s3 ls

echo "2. Verifying DynamoDB table..."
aws dynamodb list-tables --region eu-west-2

# Ask for cleanup
read -p "Do you want to destroy the created resources? (yes/no) " answer
if [ "$answer" != "yes" ]; then
    echo "Keeping resources. You can destroy them later with 'terraform destroy'"
    exit 0
fi

# Destroy resources
echo "Destroying resources..."
terraform destroy -auto-approve \
    -var="aws_account_id=${AWS_ACCOUNT_ID}" \
    -var="aws_region=eu-west-2" \
    -var="environment=${ENVIRONMENT}" \
    -var="project_name=${PROJECT_NAME}"

# Restore original files
echo "Restoring original configuration..."
mv main.tf main-local.tf
mv main.tf.bak main.tf
