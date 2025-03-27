#!/bin/bash#!/bin/bash
echo "This script is deprecated. Please use 'make migrate' instead."
exit 1

# Set environment variables
export BUCKET_NAME="terraform-state-bucket"
export TABLE_NAME="s3-lock-table"

# Export local state
terraform state pull > local.tfstate

# Initialize AWS backend (after configuring proper AWS credentials)
terraform init -reconfigure -backend-config=backend.hcl

# Import existing resources
# Note: These commands will only work if you have AWS credentials configured
# and the resources already exist in AWS
terraform import aws_s3_bucket.remote_state $BUCKET_NAME
terraform import aws_dynamodb_table.remote_locks $TABLE_NAME

# Push state to remote
terraform state push local.tfstate

echo "Migration complete. Please verify that the state was successfully migrated."
