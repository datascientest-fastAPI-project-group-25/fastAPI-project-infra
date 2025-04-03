#!/bin/bash

# This script provides mock AWS operations for local testing with Act
# It simulates AWS operations without actually making API calls

echo "Running in mock mode for local testing with Act"

# Mock S3 bucket operations
mock_s3_create_bucket() {
  local bucket_name=$1
  echo "MOCK: Created S3 bucket: $bucket_name"
  return 0
}

# Mock DynamoDB operations
mock_dynamodb_create_table() {
  local table_name=$1
  echo "MOCK: Created DynamoDB table: $table_name"
  return 0
}

# Mock IAM operations
mock_iam_get_role() {
  local role_name=$1
  if [[ "$role_name" == "FastAPIProjectBootstrapInfraRole" ]]; then
    echo "MOCK: Role exists: $role_name"
    return 0
  else
    echo "MOCK: Role does not exist: $role_name"
    return 1
  fi
}

# Mock Terraform operations
mock_terraform_init() {
  echo "MOCK: Terraform initialized"
  return 0
}

mock_terraform_apply() {
  echo "MOCK: Terraform applied successfully"
  return 0
}

# Export the mock functions
export -f mock_s3_create_bucket
export -f mock_dynamodb_create_table
export -f mock_iam_get_role
export -f mock_terraform_init
export -f mock_terraform_apply
