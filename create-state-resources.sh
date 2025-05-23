#!/bin/bash

# Script to create S3 bucket and DynamoDB table for Terraform state

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1
# Check if AWS_ACCOUNT_ID is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: AWS_ACCOUNT_ID environment variable is not set."
    echo "Please set it before running this script:"
    echo "export AWS_ACCOUNT_ID=221082192409"
    exit 1
fi
export PROJECT_NAME=fastAPI-project
export ENVIRONMENT=dev

# S3 bucket name
BUCKET_NAME="${PROJECT_NAME}-terraform-state-${AWS_ACCOUNT_ID}"

# DynamoDB table name
TABLE_NAME="${PROJECT_NAME}-terraform-state-lock-${ENVIRONMENT}"

echo "Creating S3 bucket for Terraform state..."
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $AWS_DEFAULT_REGION

# Enable versioning on the S3 bucket
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

# Enable server-side encryption for the S3 bucket
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true
            }
        ]
    }'

# Block public access to the S3 bucket
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Creating DynamoDB table for Terraform state locking..."
aws dynamodb create-table \
    --table-name $TABLE_NAME \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $AWS_DEFAULT_REGION

echo "Terraform state resources created successfully!"
