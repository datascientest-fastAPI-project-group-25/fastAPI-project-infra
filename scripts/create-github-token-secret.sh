#!/bin/bash

# Script to create the GitHub token secret in AWS Secrets Manager

set -e

# Check if GitHub token is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <github_token>"
  echo "Example: $0 ghp_1234567890abcdef"
  exit 1
fi

GITHUB_TOKEN=$1
SECRET_NAME="github/machine-user-token"
AWS_REGION=${AWS_DEFAULT_REGION:-us-east-1}

echo "Creating GitHub token secret in AWS Secrets Manager..."
echo "Secret Name: $SECRET_NAME"
echo "AWS Region: $AWS_REGION"

# Create the secret
aws secretsmanager create-secret \
  --name $SECRET_NAME \
  --description "GitHub Machine User PAT for GHCR authentication" \
  --secret-string "$GITHUB_TOKEN" \
  --region $AWS_REGION

echo "Secret created successfully!"
echo "You can now use this secret in your Terraform configuration."
