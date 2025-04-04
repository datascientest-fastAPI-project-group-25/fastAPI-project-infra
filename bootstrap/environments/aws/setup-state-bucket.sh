#!/bin/bash

# Source environment variables
source ../../scripts/load-env.sh

# Construct bucket name using AWS account ID
BUCKET_NAME="fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "Setting up state bucket: ${BUCKET_NAME} in region: ${REGION}"

echo "Checking for existing bucket..."
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "Found existing bucket. Checking its region..."
    CURRENT_REGION=$(aws s3api get-bucket-location --bucket "${BUCKET_NAME}" --query "LocationConstraint" --output text)

    if [ "${CURRENT_REGION}" != "${REGION}" ]; then
        echo "Bucket exists in ${CURRENT_REGION}. Deleting for DSGVO compliance..."
        aws s3 rb "s3://${BUCKET_NAME}" --force
    else
        echo "Bucket already exists in correct region ${REGION}"
        exit 0
    fi
fi

echo "Creating new state bucket in ${REGION}..."
if [ "${REGION}" = "us-east-1" ]; then
    # us-east-1 doesn't use LocationConstraint parameter
    aws s3api create-bucket \
        --bucket "${BUCKET_NAME}" \
        --region "${REGION}"
else
    aws s3api create-bucket \
        --bucket "${BUCKET_NAME}" \
        --region "${REGION}" \
        --create-bucket-configuration LocationConstraint="${REGION}"
fi

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

# Create DynamoDB table for state locking
DYNAMODB_TABLE="terraform-state-lock"
echo "Checking if DynamoDB table already exists..."
if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${REGION}" &>/dev/null; then
    echo "DynamoDB table ${DYNAMODB_TABLE} already exists. Skipping creation."
else
    echo "Creating DynamoDB table for state locking..."
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "${REGION}" || echo "Failed to create DynamoDB table. You may not have permissions to create it."
fi

echo "State bucket and DynamoDB setup complete in ${REGION}"
