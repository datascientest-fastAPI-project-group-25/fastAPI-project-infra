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
fi

echo "Using AWS Account: $AWS_ACCOUNT_ID"

# Test S3 bucket in us-east-1
echo "Testing S3 bucket in us-east-1..."
BUCKET_NAME="fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
aws s3 ls "s3://${BUCKET_NAME}" --region us-east-1 || echo "Cannot access bucket ${BUCKET_NAME}"

# Test creating a test file in the bucket
echo "Creating test file in S3 bucket..."
echo "This is a test file" > /tmp/test-file.txt
aws s3 cp /tmp/test-file.txt "s3://${BUCKET_NAME}/test-file.txt" --region us-east-1 || echo "Cannot upload to bucket ${BUCKET_NAME}"

# Test listing the bucket contents
echo "Listing bucket contents..."
aws s3 ls "s3://${BUCKET_NAME}" --region us-east-1 || echo "Cannot list bucket ${BUCKET_NAME}"

# Test EU region resources
echo "Testing EU region (eu-west-2) resources..."
echo "Checking for existing DynamoDB tables..."
aws dynamodb list-tables --region eu-west-2 || echo "Cannot list DynamoDB tables in eu-west-2"

# Clean up
echo "Cleaning up test file..."
aws s3 rm "s3://${BUCKET_NAME}/test-file.txt" --region us-east-1 || echo "Cannot remove test file from bucket ${BUCKET_NAME}"

echo "Test complete"
