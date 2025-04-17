#!/bin/bash

# Load environment variables using the central script
# Assumes ENV is set appropriately before calling this script (e.g., ENV=test)
. "$(dirname "${BASH_SOURCE[0]}")/../bootstrap/scripts/load-env.sh"

# Check if required variables are loaded
: "${TF_STATE_BUCKET?TF_STATE_BUCKET not set or empty}"
: "${TF_STATE_REGION?TF_STATE_REGION not set or empty}"

echo "Using S3 Bucket: $TF_STATE_BUCKET in Region: $TF_STATE_REGION"

# Determine Terraform directory based on ENV_TYPE
TF_DIR="bootstrap/environments/${ENV_TYPE}"
echo "Using Terraform directory: $TF_DIR"

# Check if the bucket exists
if aws s3api head-bucket --bucket "$TF_STATE_BUCKET" 2>/dev/null; then
  echo "S3 bucket '$TF_STATE_BUCKET' already exists."
else
  echo "Creating S3 bucket '$TF_STATE_BUCKET' in region '$TF_STATE_REGION'..."
  aws s3api create-bucket --bucket "$TF_STATE_BUCKET" --region "$TF_STATE_REGION" --create-bucket-configuration LocationConstraint=$TF_STATE_REGION
  echo "Enabling versioning for bucket '$TF_STATE_BUCKET'..."
  aws s3api put-bucket-versioning --bucket "$TF_STATE_BUCKET" --versioning-configuration Status=Enabled
  echo "Bucket created and versioning enabled."
fi

# Change to terraform directory
cd "$TF_DIR" || { echo "Error: Directory $TF_DIR not found"; exit 1; }

# Check if backend.tf exists
if [ -f backend.tf ]; then
  # Temporarily rename backend.tf to disable S3 backend
  mv backend.tf backend.tf.bak

  # Initialize Terraform with local backend
  terraform init -reconfigure

  # Apply Terraform configuration to create S3 bucket and DynamoDB table
  terraform apply -auto-approve

  # Restore backend.tf to enable S3 backend
  mv backend.tf.bak backend.tf

  # Initialize Terraform with S3 backend
  terraform init -reconfigure -migrate-state
else
  echo "Warning: backend.tf not found in $TF_DIR. Skipping state migration."
  # Initialize Terraform with local backend
  terraform init -reconfigure

  # Apply Terraform configuration
  terraform apply -auto-approve
fi

echo "Terraform state has been successfully migrated to S3!"
