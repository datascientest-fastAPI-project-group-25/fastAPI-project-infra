#!/bin/bash

# Script to destroy infrastructure using the -target approach to resolve for_each errors
# This script is used to destroy infrastructure in two steps:
# 1. First, destroy everything except the resources that the for_each depends on
# 2. Then, destroy the remaining resources (IAM roles, etc.)

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

echo "=== Destroying infrastructure for $ENVIRONMENT environment ==="
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo "Directory: $DIR"
echo "Backend Config: $BACKEND_CONFIG"
echo "Plan Only: $PLAN_ONLY"

# Confirm destruction if not in plan-only mode
if [ "$PLAN_ONLY" = false ]; then
  read -p "Are you sure you want to destroy the $ENVIRONMENT environment? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Destruction aborted."
    exit 1
  fi
fi

# Change to the directory
cd $DIR

# Initialize Terraform
echo "=== Initializing Terraform ==="
terraform init -backend-config=$BACKEND_CONFIG

# First, destroy everything except the resources that the for_each depends on
echo "=== Step 1: Destroying most resources ==="
echo "This step will destroy all resources except the IAM roles and other resources that the for_each depends on."

if [ "$PLAN_ONLY" = true ]; then
  # Plan only - use -lock=false to avoid state lock errors in CI/CD
  terraform plan -lock=false -destroy -var-file=terraform.tfvars -out=destroy.tfplan
else
  # Create a temporary plan file and apply it with auto-approve
  # Add -lock=false to avoid state lock errors in CI/CD
  terraform plan -lock=false -destroy -var-file=terraform.tfvars -out=destroy.tfplan
  terraform apply -auto-approve -lock=false destroy.tfplan
fi

# Now, destroy the remaining resources (IAM roles, etc.)
echo "=== Step 2: Destroying remaining resources ==="
echo "This step will destroy the IAM roles and other resources that the for_each depends on."

if [ "$PLAN_ONLY" = true ]; then
  # Plan only - use -lock=false to avoid state lock errors in CI/CD
  terraform plan -lock=false -destroy -var-file=terraform.tfvars \
    -target=module.eks.module.eks.aws_iam_role.this[0] \
    -target=module.eks.module.eks.data.aws_partition.current \
    -target=module.eks.module.eks.data.aws_caller_identity.current \
    -out=destroy-step2.tfplan
else
  # Apply with auto-approve for CI/CD environments
  # Add -lock=false to avoid state lock errors
  terraform destroy -auto-approve -lock=false -var-file=terraform.tfvars \
    -target=module.eks.module.eks.aws_iam_role.this[0] \
    -target=module.eks.module.eks.data.aws_partition.current \
    -target=module.eks.module.eks.data.aws_caller_identity.current
fi

# Final destroy to make sure everything is gone
echo "=== Step 3: Final verification destroy ==="
if [ "$PLAN_ONLY" = true ]; then
  # Plan only - use -lock=false to avoid state lock errors in CI/CD
  terraform plan -lock=false -destroy -var-file=terraform.tfvars -out=destroy-final.tfplan
else
  # Apply with auto-approve for CI/CD environments
  # Add -lock=false to avoid state lock errors
  terraform destroy -auto-approve -lock=false -var-file=terraform.tfvars

  # Clean up
  rm -f destroy.tfplan
fi

if [ "$PLAN_ONLY" = true ]; then
  echo "=== Planning complete ==="
else
  echo "=== Destruction complete ==="
fi
