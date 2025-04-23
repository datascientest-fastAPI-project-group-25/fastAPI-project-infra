#!/bin/bash

# Set environment variables
export AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID ../.env | cut -d= -f2)
export AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY ../.env | cut -d= -f2)
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-221082192409}
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev

# Set bucket and table names
BUCKET_NAME="fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
DYNAMODB_TABLE="terraform-state-lock-test"

echo "Setting up Terraform state resources in AWS..."
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"
echo "State Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"

# Check if bucket exists
echo "Checking if bucket exists..."
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "Bucket already exists"
else
    echo "Creating bucket..."
    aws s3api create-bucket \
        --bucket "${BUCKET_NAME}" \
        --region "${AWS_DEFAULT_REGION}"

    echo "Enabling versioning..."
    aws s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Enabled

    echo "Enabling encryption..."
    aws s3api put-bucket-encryption \
        --bucket "${BUCKET_NAME}" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'

    echo "Setting public access block..."
    aws s3api put-public-access-block \
        --bucket "${BUCKET_NAME}" \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    echo "Adding bucket policy..."
    BUCKET_POLICY='{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "EnforceTLSRequestsOnly",
                "Effect": "Deny",
                "Principal": "*",
                "Action": "s3:*",
                "Resource": [
                    "arn:aws:s3:::'"${BUCKET_NAME}"'",
                    "arn:aws:s3:::'"${BUCKET_NAME}"'/*"
                ],
                "Condition": {
                    "Bool": {
                        "aws:SecureTransport": "false"
                    }
                }
            }
        ]
    }'

    echo "${BUCKET_POLICY}" | aws s3api put-bucket-policy \
        --bucket "${BUCKET_NAME}" \
        --policy file:///dev/stdin
fi

# Check if DynamoDB table exists
echo "Checking if DynamoDB table exists..."
if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${AWS_DEFAULT_REGION}" > /dev/null 2>&1; then
    echo "DynamoDB table already exists"
else
    echo "Creating DynamoDB table..."
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "${AWS_DEFAULT_REGION}"
fi

echo "State resources setup complete!"
echo "S3 Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo "Region: $AWS_DEFAULT_REGION"
