#!/bin/bash

# Script to set up AWS credentials from .env file
# This ensures we're using the correct AWS account

# Check if .env file exists
if [ ! -f .env ]; then
  echo "Error: .env file not found"
  exit 1
fi

# Extract credentials from .env file
export AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID .env | cut -d= -f2)
export AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY .env | cut -d= -f2)
export AWS_DEFAULT_REGION=$(grep AWS_DEFAULT_REGION .env | cut -d= -f2 || echo "us-east-1")
export AWS_ACCOUNT_ID=$(grep AWS_ACCOUNT_ID .env | cut -d= -f2)

# Verify we're using the correct account
echo "Verifying AWS credentials..."
CALLER_IDENTITY=$(aws sts get-caller-identity)
ACTUAL_ACCOUNT_ID=$(echo "$CALLER_IDENTITY" | grep -o '"Account": "[0-9]*"' | cut -d\" -f4)

if [ "$ACTUAL_ACCOUNT_ID" != "$AWS_ACCOUNT_ID" ]; then
  echo "Error: AWS account ID mismatch. Expected $AWS_ACCOUNT_ID but got $ACTUAL_ACCOUNT_ID"
  exit 1
fi

echo "AWS credentials set up successfully"
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"

# Configure AWS CLI to use these credentials
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $AWS_DEFAULT_REGION

# Verify configuration
aws configure list
