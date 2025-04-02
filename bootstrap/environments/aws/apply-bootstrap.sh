#!/bin/bash

# Source environment loading script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../scripts/load-env.sh"

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
    echo "AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID" >> ../../.env.bootstrap
fi

echo "Using AWS Account: $AWS_ACCOUNT_ID"

# Check if state bucket exists
BUCKET_NAME="fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
echo "Checking for state bucket: $BUCKET_NAME"
if ! aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "Error: State bucket does not exist. Please run setup-state-bucket.sh first."
    exit 1
fi

# Check if DynamoDB table exists
DYNAMODB_TABLE="terraform-state-lock"
echo "Checking for DynamoDB table: $DYNAMODB_TABLE"
if ! aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${AWS_DEFAULT_REGION}" > /dev/null 2>&1; then
    echo "Error: DynamoDB table does not exist. Please run setup-state-bucket.sh first."
    exit 1
fi

# Initialize Terraform with backend configuration
echo "Initializing Terraform..."
terraform init -reconfigure \
    -backend-config=backend.hcl \
    -backend-config="bucket=${BUCKET_NAME}"

# Create a temporary main.tf file that excludes state resources
echo "Creating temporary configuration to avoid state resource conflicts..."
cp main.tf main.tf.bak

# Apply only the logging and security modules
echo "Applying only the necessary resources..."
terraform apply -auto-approve \
    -target=module.logging.aws_s3_bucket.logging_bucket \
    -target=module.security.aws_iam_role.github_actions_bootstrap_role \
    -target=module.security.aws_lambda_function.s3_event_lambda \
    -var="aws_account_id=${AWS_ACCOUNT_ID}" \
    -var="aws_region=${AWS_DEFAULT_REGION}" \
    -var="environment=${ENVIRONMENT}" \
    -var="project_name=${PROJECT_NAME}"

# Restore original main.tf
echo "Restoring original configuration..."
mv main.tf.bak main.tf

echo "Bootstrap complete! The following resources have been created:"
echo "1. Logging bucket for storing access logs"
echo "2. IAM roles for GitHub Actions"
echo "3. Lambda function for S3 event processing"

echo "You can now use these resources with your FastAPI project."
