#!/bin/bash

# Source environment variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../scripts/load-env.sh"

# Check for jq (required for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Attempting to install..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y jq
    elif command -v yum &> /dev/null; then
        yum install -y jq
    elif command -v brew &> /dev/null; then
        brew install jq
    else
        echo "Error: Could not install jq. Please install it manually and try again."
        exit 1
    fi
fi

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

# Set region to us-east-1 for the bucket
export AWS_DEFAULT_REGION="us-east-1"
REGION="us-east-1"
BUCKET_NAME="fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"

echo "=== STEP 1: Creating state bucket in ${REGION} ==="
echo "Setting up state bucket: ${BUCKET_NAME} in region: ${REGION}"

echo "Checking for existing bucket..."
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "Found existing bucket. Checking its region..."
    CURRENT_REGION=$(aws s3api get-bucket-location --bucket "${BUCKET_NAME}" --query "LocationConstraint" --output text)

    if [ "${CURRENT_REGION}" != "${REGION}" ] && [ "${CURRENT_REGION}" != "None" ]; then
        echo "Bucket exists in ${CURRENT_REGION}. Deleting for DSGVO compliance..."
        aws s3 rb "s3://${BUCKET_NAME}" --force
    else
        echo "Bucket already exists in correct region ${REGION}"
    fi
fi

echo "Creating new state bucket in ${REGION}..."
# us-east-1 doesn't use LocationConstraint parameter
aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}"

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

echo "=== STEP 2: Testing the bucket ==="
# Test S3 bucket in us-east-1
echo "Testing S3 bucket in us-east-1..."
aws s3 ls "s3://${BUCKET_NAME}" --region us-east-1 || {
    echo "Cannot access bucket ${BUCKET_NAME}"
    exit 1
}

# Test creating a test file in the bucket
echo "Creating test file in S3 bucket..."
echo "This is a test file" > /tmp/test-file.txt
aws s3 cp /tmp/test-file.txt "s3://${BUCKET_NAME}/test-file.txt" --region us-east-1 || {
    echo "Cannot upload to bucket ${BUCKET_NAME}"
    exit 1
}

# Test listing the bucket contents
echo "Listing bucket contents..."
aws s3 ls "s3://${BUCKET_NAME}" --region us-east-1 || {
    echo "Cannot list bucket ${BUCKET_NAME}"
    exit 1
}

# Clean up test file
echo "Cleaning up test file..."
aws s3 rm "s3://${BUCKET_NAME}/test-file.txt" --region us-east-1 || {
    echo "Cannot remove test file from bucket ${BUCKET_NAME}"
    exit 1
}

echo "=== STEP 3: Destroying the bucket ==="
echo "Emptying bucket (including all versions)..."

# Function to delete all versions and markers
delete_all_versions() {
    local bucket=$1
    local region=$2

    # Keep looping until no more objects/versions are found
    while true; do
        # List all object versions and delete markers
        VERSIONS=$(aws s3api list-object-versions --bucket "${bucket}" --region "${region}" --output json 2>/dev/null)

        # Check if we have any objects to delete
        OBJECTS=$(echo "$VERSIONS" | jq -r '.Versions[]? | {Key:.Key, VersionId:.VersionId}' 2>/dev/null)
        DELETE_MARKERS=$(echo "$VERSIONS" | jq -r '.DeleteMarkers[]? | {Key:.Key, VersionId:.VersionId}' 2>/dev/null)

        # If no objects or markers, we're done
        if [ -z "$OBJECTS" ] && [ -z "$DELETE_MARKERS" ]; then
            echo "Bucket is empty of all versions."
            break
        fi

        # Create a JSON file for the delete operation
        echo '{"Objects": []}' > /tmp/delete_objects.json

        # Add objects to the delete file
        if [ -n "$OBJECTS" ]; then
            echo "$OBJECTS" | jq -c '.' | while read -r obj; do
                KEY=$(echo "$obj" | jq -r '.Key')
                VERSION_ID=$(echo "$obj" | jq -r '.VersionId')
                echo "Adding object for deletion: $KEY (version: $VERSION_ID)"
                jq --arg key "$KEY" --arg vid "$VERSION_ID" '.Objects += [{"Key": $key, "VersionId": $vid}]' /tmp/delete_objects.json > /tmp/delete_objects_tmp.json
                mv /tmp/delete_objects_tmp.json /tmp/delete_objects.json
            done
        fi

        # Add delete markers to the delete file
        if [ -n "$DELETE_MARKERS" ]; then
            echo "$DELETE_MARKERS" | jq -c '.' | while read -r marker; do
                KEY=$(echo "$marker" | jq -r '.Key')
                VERSION_ID=$(echo "$marker" | jq -r '.VersionId')
                echo "Adding delete marker for deletion: $KEY (version: $VERSION_ID)"
                jq --arg key "$KEY" --arg vid "$VERSION_ID" '.Objects += [{"Key": $key, "VersionId": $vid}]' /tmp/delete_objects.json > /tmp/delete_objects_tmp.json
                mv /tmp/delete_objects_tmp.json /tmp/delete_objects.json
            done
        fi

        # Check if we have objects to delete
        OBJECT_COUNT=$(jq '.Objects | length' /tmp/delete_objects.json)
        if [ "$OBJECT_COUNT" -gt 0 ]; then
            echo "Deleting $OBJECT_COUNT objects/markers in batch..."
            aws s3api delete-objects --bucket "${bucket}" --delete file:///tmp/delete_objects.json --region "${region}"
        else
            echo "No objects to delete."
            break
        fi
    done

    # Also do a regular recursive delete for good measure
    echo "Performing recursive delete for any remaining objects..."
    aws s3 rm "s3://${bucket}" --recursive --region "${region}"
}

# Delete all versions from the bucket
delete_all_versions "${BUCKET_NAME}" "us-east-1"

echo "Deleting bucket..."
aws s3api delete-bucket --bucket "${BUCKET_NAME}" --region us-east-1

echo "Deleting DynamoDB table..."
aws dynamodb delete-table --table-name "${DYNAMODB_TABLE}" --region us-east-1 || echo "Could not delete DynamoDB table. It may not exist or you don't have permissions."

echo "Dryrun complete! All resources have been created, tested, and destroyed."
