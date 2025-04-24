#!/bin/bash

# Script to deploy infrastructure using the -target approach to resolve for_each errors
# This script is used to deploy infrastructure in two steps:
# 1. First, deploy only the resources that the for_each depends on
# 2. Then, deploy the rest of the infrastructure

set -e

# Check if environment is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <environment> [aws_account_id] [aws_region] [--plan-only]"
  echo "Example: $0 stg 123456789012 us-east-1"
  echo "Valid environments: stg, prod"
  echo "Use --plan-only to only create plans without applying them"
  exit 1
fi

# Set variables
ENVIRONMENT=$1
AWS_ACCOUNT_ID=${2:-$AWS_ACCOUNT_ID}
AWS_REGION=${3:-$AWS_DEFAULT_REGION}
PLAN_ONLY=false

# Check for --plan-only flag
if [[ "$*" == *"--plan-only"* ]]; then
  PLAN_ONLY=true
  echo "Plan-only mode enabled. Will not apply changes."
fi

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

echo "=== Deploying infrastructure for $ENVIRONMENT environment ==="
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo "Directory: $DIR"
echo "Backend Config: $BACKEND_CONFIG"
echo "Plan Only: $PLAN_ONLY"

# Change to the directory
cd $DIR

# Initialize Terraform
echo "=== Initializing Terraform ==="
terraform init -backend-config=$BACKEND_CONFIG

# First, deploy only the resources that the for_each depends on
echo "=== Step 1: Deploying resources that for_each depends on ==="
echo "This step will deploy the IAM roles and other resources that the for_each depends on."
echo "This will resolve the 'Invalid for_each argument' error."

# Target the IAM roles and other resources that the for_each depends on
if [ "$PLAN_ONLY" = true ]; then
  # Plan only
  terraform plan -var-file=terraform.tfvars \
    -target=module.eks.module.eks.aws_iam_role.this[0] \
    -target=module.eks.module.eks.data.aws_partition.current \
    -target=module.eks.module.eks.data.aws_caller_identity.current \
    -out=tfplan-step1
else
  # Apply
  terraform apply -var-file=terraform.tfvars \
    -target=module.eks.module.eks.aws_iam_role.this[0] \
    -target=module.eks.module.eks.data.aws_partition.current \
    -target=module.eks.module.eks.data.aws_caller_identity.current
fi

# Now, deploy the rest of the infrastructure
echo "=== Step 2: Deploying the rest of the infrastructure ==="
if [ "$PLAN_ONLY" = true ]; then
  # Plan only
  terraform plan -var-file=terraform.tfvars -out=tfplan
else
  # Apply
  terraform apply -var-file=terraform.tfvars
fi

if [ "$PLAN_ONLY" = true ]; then
  echo "=== Planning complete ==="
else
  echo "=== Deployment complete ==="
fi
