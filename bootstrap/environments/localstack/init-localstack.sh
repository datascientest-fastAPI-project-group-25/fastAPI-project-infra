#!/bin/bash

echo "Initializing LocalStack resources..."

# Set localstack endpoint
# Use "localstack" as the hostname when running in Docker, otherwise use "localhost"
if [ -n "$LOCALSTACK_ENDPOINT" ]; then
    echo "Using provided LOCALSTACK_ENDPOINT: $LOCALSTACK_ENDPOINT"
else
    # Check if we're running in Docker
    if [ -f "/.dockerenv" ]; then
        export LOCALSTACK_ENDPOINT="http://localstack:4566"
    else
        export LOCALSTACK_ENDPOINT="http://localhost:4566"
    fi
fi

echo "Using LocalStack endpoint: $LOCALSTACK_ENDPOINT"

# Create S3 buckets
echo "Creating S3 buckets..."
aws --endpoint-url=$LOCALSTACK_ENDPOINT s3 mb s3://localstack-s3-bucket
aws --endpoint-url=$LOCALSTACK_ENDPOINT s3 mb s3://localstack-logs-bucket

# Create DynamoDB table
echo "Creating DynamoDB table..."
aws --endpoint-url=$LOCALSTACK_ENDPOINT dynamodb create-table \
    --table-name terraform-state-lock-local \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Verify resources
echo -e "\nVerifying S3 buckets:"
aws --endpoint-url=$LOCALSTACK_ENDPOINT s3 ls

echo -e "\nVerifying DynamoDB table:"
aws --endpoint-url=$LOCALSTACK_ENDPOINT dynamodb list-tables
