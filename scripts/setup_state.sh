#!/bin/bash

# Load environment variables
source .env.test

# Change to terraform directory
cd terraform

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

echo "Terraform state has been successfully migrated to S3!"
