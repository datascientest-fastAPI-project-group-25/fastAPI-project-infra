#!/bin/bash

# Source environment variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../scripts/load-env.sh"

# Set localstack endpoint
export LOCALSTACK_ENDPOINT="http://localhost:4566"
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ACCOUNT_ID="123456789012"

echo "Using LocalStack endpoint: ${LOCALSTACK_ENDPOINT}"
echo "Using dummy AWS Account: ${AWS_ACCOUNT_ID}"

# Set bucket name
BUCKET_NAME="fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
REGION="us-east-1"

echo "=== STEP 1: Creating state bucket in LocalStack ==="
echo "Setting up state bucket: ${BUCKET_NAME}"

echo "Checking for existing bucket..."
if aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "Found existing bucket. Deleting it for a clean test..."
    aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3 rb "s3://${BUCKET_NAME}" --force
fi

echo "Creating new state bucket in LocalStack..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}"

echo "Enabling versioning..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled

echo "Enabling encryption..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api put-bucket-encryption \
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

# Create DynamoDB table for state locking
DYNAMODB_TABLE="terraform-state-lock"
echo "Creating DynamoDB table for state locking..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} dynamodb create-table \
    --table-name "${DYNAMODB_TABLE}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}" || echo "DynamoDB table may already exist."

echo "State bucket and DynamoDB setup complete in LocalStack"

echo "=== STEP 2: Testing the bucket ==="
echo "Testing S3 bucket in LocalStack..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3 ls "s3://${BUCKET_NAME}" || {
    echo "Cannot access bucket ${BUCKET_NAME}"
    exit 1
}

echo "Creating test file in S3 bucket..."
echo "This is a test file" > /tmp/test-file.txt
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3 cp /tmp/test-file.txt "s3://${BUCKET_NAME}/test-file.txt" || {
    echo "Cannot upload to bucket ${BUCKET_NAME}"
    exit 1
}

echo "Listing bucket contents..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3 ls "s3://${BUCKET_NAME}" || {
    echo "Cannot list bucket ${BUCKET_NAME}"
    exit 1
}

echo "Downloading test file..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3 cp "s3://${BUCKET_NAME}/test-file.txt" /tmp/test-file-downloaded.txt || {
    echo "Cannot download from bucket ${BUCKET_NAME}"
    exit 1
}

echo "Verifying file contents..."
if [ "$(cat /tmp/test-file.txt)" = "$(cat /tmp/test-file-downloaded.txt)" ]; then
    echo "File contents match!"
else
    echo "File contents do not match!"
    exit 1
fi

echo "=== STEP 3: Destroying the bucket ==="
echo "Emptying bucket (including all versions)..."
# List all object versions and delete markers
VERSIONS=$(aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api list-object-versions --bucket "${BUCKET_NAME}" --output json --query '{Objects: Objects[].{Key:Key,VersionId:VersionId}, DeleteMarkers: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' 2>/dev/null)

# Check if there are any objects or delete markers
if [ -n "$VERSIONS" ] && [ "$VERSIONS" != "{}" ]; then
    # Extract and delete objects
    OBJECTS=$(echo "$VERSIONS" | jq -r '.Objects')
    if [ -n "$OBJECTS" ] && [ "$OBJECTS" != "null" ]; then
        echo "Deleting object versions..."
        for OBJ in $(echo "$OBJECTS" | jq -c '.[]'); do
            KEY=$(echo "$OBJ" | jq -r '.Key')
            VERSION_ID=$(echo "$OBJ" | jq -r '.VersionId')
            echo "Deleting object: $KEY (version: $VERSION_ID)"
            aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api delete-object --bucket "${BUCKET_NAME}" --key "$KEY" --version-id "$VERSION_ID"
        done
    fi

    # Extract and delete delete markers
    DELETE_MARKERS=$(echo "$VERSIONS" | jq -r '.DeleteMarkers')
    if [ -n "$DELETE_MARKERS" ] && [ "$DELETE_MARKERS" != "null" ]; then
        echo "Deleting delete markers..."
        for MARKER in $(echo "$DELETE_MARKERS" | jq -c '.[]'); do
            KEY=$(echo "$MARKER" | jq -r '.Key')
            VERSION_ID=$(echo "$MARKER" | jq -r '.VersionId')
            echo "Deleting delete marker: $KEY (version: $VERSION_ID)"
            aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api delete-object --bucket "${BUCKET_NAME}" --key "$KEY" --version-id "$VERSION_ID"
        done
    fi
fi

# Also do a regular recursive delete for good measure
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3 rm "s3://${BUCKET_NAME}" --recursive

echo "Deleting bucket..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api delete-bucket --bucket "${BUCKET_NAME}"

echo "Deleting DynamoDB table..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} dynamodb delete-table --table-name "${DYNAMODB_TABLE}" || echo "Could not delete DynamoDB table. It may not exist."

echo "LocalStack dryrun complete! All resources have been created, tested, and destroyed."
