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

# Function to delete all versions and markers in LocalStack
delete_all_versions_localstack() {
    local bucket=$1
    local endpoint=$2

    # Keep looping until no more objects/versions are found
    while true; do
        # List all object versions and delete markers
        VERSIONS=$(aws --endpoint-url=${endpoint} s3api list-object-versions --bucket "${bucket}" --output json 2>/dev/null)

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
            aws --endpoint-url=${endpoint} s3api delete-objects --bucket "${bucket}" --delete file:///tmp/delete_objects.json
        else
            echo "No objects to delete."
            break
        fi
    done

    # Also do a regular recursive delete for good measure
    echo "Performing recursive delete for any remaining objects..."
    aws --endpoint-url=${endpoint} s3 rm "s3://${bucket}" --recursive
}

echo "Using LocalStack endpoint: ${LOCALSTACK_ENDPOINT}"
echo "Using dummy AWS Account: ${AWS_ACCOUNT_ID}"

# Set bucket name
BUCKET_NAME="fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
REGION="us-east-1"

echo "=== STEP 1: Creating state bucket in LocalStack ==="
echo "Setting up state bucket: ${BUCKET_NAME}"

echo "Checking for existing bucket..."
if aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "Found existing bucket. Emptying and deleting it for a clean test..."
    # Empty the bucket first
    delete_all_versions_localstack "${BUCKET_NAME}" "${LOCALSTACK_ENDPOINT}"
    # Now delete the empty bucket
    aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api delete-bucket --bucket "${BUCKET_NAME}"
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

# Function to delete all versions and markers in LocalStack
delete_all_versions_localstack() {
    local bucket=$1
    local endpoint=$2

    # Keep looping until no more objects/versions are found
    while true; do
        # List all object versions and delete markers
        VERSIONS=$(aws --endpoint-url=${endpoint} s3api list-object-versions --bucket "${bucket}" --output json 2>/dev/null)

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
            aws --endpoint-url=${endpoint} s3api delete-objects --bucket "${bucket}" --delete file:///tmp/delete_objects.json
        else
            echo "No objects to delete."
            break
        fi
    done

    # Also do a regular recursive delete for good measure
    echo "Performing recursive delete for any remaining objects..."
    aws --endpoint-url=${endpoint} s3 rm "s3://${bucket}" --recursive
}

# Delete all versions from the bucket
delete_all_versions_localstack "${BUCKET_NAME}" "${LOCALSTACK_ENDPOINT}"

echo "Deleting bucket..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} s3api delete-bucket --bucket "${BUCKET_NAME}"

echo "Deleting DynamoDB table..."
aws --endpoint-url=${LOCALSTACK_ENDPOINT} dynamodb delete-table --table-name "${DYNAMODB_TABLE}" || echo "Could not delete DynamoDB table. It may not exist."

echo "LocalStack dryrun complete! All resources have been created, tested, and destroyed."
