#!/bin/bash
# Script to safely update Terraform state by removing resources that no longer exist
# This script should be used with extreme caution as it modifies the Terraform state

# Exit on error
set -e

# Check if environment is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <environment> [aws_account_id] [aws_region]"
  echo "Example: $0 prod 123456789012 us-east-1"
  exit 1
fi

# Set variables
ENVIRONMENT=$1
AWS_ACCOUNT_ID=${2:-$(aws sts get-caller-identity --query Account --output text)}
AWS_REGION=${3:-"us-east-1"}

echo "=== State Update Script for $ENVIRONMENT Environment ==="
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"

# Create backend config file - use a path that works on both Windows and Unix
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  # Windows path
  BACKEND_CONFIG="$TEMP/backend-config-$ENVIRONMENT.tfbackend"
else
  # Unix path
  BACKEND_CONFIG="/tmp/backend-config-$ENVIRONMENT.tfbackend"
fi

echo "bucket = \"fastapi-project-terraform-state-$AWS_ACCOUNT_ID\"" > "$BACKEND_CONFIG"
echo "key = \"fastapi/infra/$ENVIRONMENT/terraform.tfstate\"" >> "$BACKEND_CONFIG"
echo "region = \"$AWS_REGION\"" >> "$BACKEND_CONFIG"
echo "dynamodb_table = \"terraform-state-lock\"" >> "$BACKEND_CONFIG"

# Function to backup the Terraform state
backup_terraform_state() {
  local timestamp=$(date +%Y%m%d%H%M%S)
  local state_key="fastapi/infra/$ENVIRONMENT/terraform.tfstate"
  local backup_key="fastapi/infra/$ENVIRONMENT/backups/terraform.tfstate.$timestamp"
  
  echo "Creating backup of Terraform state for $ENVIRONMENT environment..."
  
  # Get the S3 bucket name from the backend config
  local bucket_name=$(grep "bucket" "$BACKEND_CONFIG" | cut -d'"' -f2)
  
  # Check if the state file exists
  if aws s3 ls "s3://$bucket_name/$state_key" &> /dev/null; then
    # Create the backup
    aws s3 cp "s3://$bucket_name/$state_key" "s3://$bucket_name/$backup_key"
    echo "State backup created at s3://$bucket_name/$backup_key"
    return 0
  else
    echo "No state file found at s3://$bucket_name/$state_key. Skipping backup."
    return 0
  fi
}

# Change to the appropriate directory
cd "$(dirname "$0")/../terraform/environments/deploy/$ENVIRONMENT"

# Initialize Terraform
echo "=== Initializing Terraform ==="
terraform init -backend-config=$BACKEND_CONFIG

# Create a backup of the state file
backup_terraform_state

# List current state
echo "=== Current State Resources ==="
terraform state list

# Prompt for confirmation
echo ""
echo "WARNING: This script will remove resources from the Terraform state."
echo "This should only be done if the resources have been manually deleted from AWS."
echo "Removing resources from state that still exist in AWS will cause Terraform to recreate them."
echo ""
read -p "Are you sure you want to proceed? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Operation cancelled."
  exit 0
fi

# List of resources to remove from state
# These are resources that have been manually deleted from AWS
resources_to_remove=(
  # EKS Cluster and related resources
  "module.eks.module.eks.aws_eks_cluster.this[0]"
  "module.eks.module.eks.module.eks_managed_node_group[\"default\"].aws_eks_node_group.this[0]"
  # Add more resources as needed
)

# Remove each resource from state
echo "=== Removing Resources from State ==="
for resource in "${resources_to_remove[@]}"; do
  echo "Removing $resource from state..."
  if terraform state list | grep -q "$resource"; then
    terraform state rm "$resource" || echo "Failed to remove $resource from state"
  else
    echo "Resource $resource not found in state"
  fi
done

# List updated state
echo "=== Updated State Resources ==="
terraform state list

echo "=== State Update Complete ==="
echo "The Terraform state has been updated to remove resources that no longer exist."
echo "You can now run terraform plan to verify the changes."
