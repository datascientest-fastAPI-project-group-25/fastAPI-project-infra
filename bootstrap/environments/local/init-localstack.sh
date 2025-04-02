#!/bin/bash

echo "Initializing LocalStack resources..."

# Create S3 buckets
echo "Creating S3 buckets..."
aws --endpoint-url=http://localhost:4566 s3 mb s3://localstack-s3-bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://localstack-logs-bucket

# Create DynamoDB table
echo "Creating DynamoDB table..."
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
    --table-name terraform-state-lock-local \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Verify resources
echo -e "\nVerifying S3 buckets:"
aws --endpoint-url=http://localhost:4566 s3 ls

echo -e "\nVerifying DynamoDB table:"
aws --endpoint-url=http://localhost:4566 dynamodb list-tables