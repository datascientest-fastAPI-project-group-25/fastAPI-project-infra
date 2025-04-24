#!/bin/bash

# Script to destroy infrastructure using the -target approach to resolve for_each errors
# This script is used to destroy infrastructure in two steps:
# 1. First, destroy everything except the resources that the for_each depends on
# 2. Then, destroy the remaining resources (IAM roles, etc.)

set -e

# Check if environment is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <environment> [aws_account_id] [aws_region]"
  echo "Example: $0 stg 123456789012 us-east-1"
  echo "Valid environments: stg, prod"
  exit 1
fi

# Set variables
ENVIRONMENT=$1
AWS_ACCOUNT_ID=${2:-$AWS_ACCOUNT_ID}
AWS_REGION=${3:-$AWS_DEFAULT_REGION}

# Check if AWS_ACCOUNT_ID is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "AWS_ACCOUNT_ID is not set. Please provide it as the second argument or set it as an environment variable."
  exit 1
fi

# Check if AWS_REGION is set
if [ -z "$AWS_REGION" ]; then
  echo "AWS_REGION is not set. Please provide it as the third argument or set it as an environment variable."
  exit 1
fi

# Set directory based on environment
if [ "$ENVIRONMENT" == "stg" ] || [ "$ENVIRONMENT" == "staging" ]; then
  DIR="terraform/environments/deploy/stg"
elif [ "$ENVIRONMENT" == "prod" ] || [ "$ENVIRONMENT" == "production" ]; then
  DIR="terraform/environments/deploy/prod"
else
  echo "Invalid environment: $ENVIRONMENT"
  echo "Valid environments: stg, prod"
  exit 1
fi

# Check if directory exists
if [ ! -d "$DIR" ]; then
  echo "Directory $DIR does not exist."
  exit 1
fi

# Create backend config file
BACKEND_CONFIG="/tmp/backend-config-$ENVIRONMENT.tfbackend"
echo "bucket = \"fastapi-project-terraform-state-$AWS_ACCOUNT_ID\"" > $BACKEND_CONFIG
echo "key = \"fastapi/infra/$ENVIRONMENT/terraform.tfstate\"" >> $BACKEND_CONFIG
echo "region = \"$AWS_REGION\"" >> $BACKEND_CONFIG
echo "dynamodb_table = \"terraform-state-lock\"" >> $BACKEND_CONFIG

echo "=== Destroying infrastructure for $ENVIRONMENT environment ==="
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo "Directory: $DIR"
echo "Backend Config: $BACKEND_CONFIG"

# Confirm destruction
read -p "Are you sure you want to destroy the $ENVIRONMENT environment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Destruction aborted."
  exit 1
fi

# Change to the directory
cd $DIR

# Initialize Terraform
echo "=== Initializing Terraform ==="
terraform init -backend-config=$BACKEND_CONFIG

# First, destroy everything except the resources that the for_each depends on
echo "=== Step 1: Destroying most resources ==="
echo "This step will destroy all resources except the IAM roles and other resources that the for_each depends on."

# Create a temporary plan file
terraform plan -destroy -var-file=terraform.tfvars -out=destroy.tfplan

# Apply the destroy plan
terraform apply destroy.tfplan

# Now, destroy the remaining resources (IAM roles, etc.)
echo "=== Step 2: Destroying remaining resources ==="
echo "This step will destroy the IAM roles and other resources that the for_each depends on."

# Target the IAM roles and other resources that the for_each depends on
terraform destroy -var-file=terraform.tfvars \
  -target=module.eks.module.eks.aws_iam_role.this[0] \
  -target=module.eks.module.eks.data.aws_partition.current \
  -target=module.eks.module.eks.data.aws_caller_identity.current

# Final destroy to make sure everything is gone
echo "=== Step 3: Final verification destroy ==="
terraform destroy -var-file=terraform.tfvars

# Clean up
rm -f destroy.tfplan

echo "=== Destruction complete ==="
