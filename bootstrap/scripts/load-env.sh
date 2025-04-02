#!/bin/bash

# Function to load env file
load_env() {
    local env_file=$1
    if [ -f "$env_file" ]; then
        echo "Loading environment from $env_file"
        set -o allexport
        source "$env_file"
        set +o allexport
    else
        echo "Warning: $env_file not found"
    fi
}

# Directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load root .env first
ROOT_ENV="${SCRIPT_DIR}/../../.env"
load_env "$ROOT_ENV"

# Load bootstrap environment specific .env
BOOTSTRAP_ENV="${SCRIPT_DIR}/../.env"
load_env "$BOOTSTRAP_ENV"

# Process environment variables
# Replace any ${VAR} or $VAR in the values
for var in $(env | grep -v '^_' | cut -d= -f1); do
    val=$(eval echo "\$$var")
    export $var="$val"
done

# Verify required variables
required_vars=(
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY"
    "AWS_DEFAULT_REGION"
    "AWS_ACCOUNT_ID"
    "PROJECT_NAME"
    "ENVIRONMENT"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required variable $var is not set"
        exit 1
    fi
done

# Validate AWS_ACCOUNT_ID (should be a 12-digit number)
if ! [[ "$AWS_ACCOUNT_ID" =~ ^[0-9]{12}$ ]]; then
    echo "Error: AWS_ACCOUNT_ID should be a 12-digit number"
    exit 1
fi

# Validate AWS_DEFAULT_REGION (should be a valid AWS region)
valid_regions=(
    "us-east-1" "us-east-2" "us-west-1" "us-west-2"
    "af-south-1" "ap-east-1" "ap-south-1" "ap-northeast-1"
    "ap-northeast-2" "ap-northeast-3" "ap-southeast-1" "ap-southeast-2"
    "ca-central-1" "eu-central-1" "eu-west-1" "eu-west-2"
    "eu-west-3" "eu-south-1" "eu-north-1" "me-south-1"
    "sa-east-1"
)

region_valid=false
for region in "${valid_regions[@]}"; do
    if [ "$AWS_DEFAULT_REGION" = "$region" ]; then
        region_valid=true
        break
    fi
done

if [ "$region_valid" = false ]; then
    echo "Error: AWS_DEFAULT_REGION is not a valid AWS region"
    exit 1
fi

# Print configuration (without sensitive data)
echo "Environment Configuration:"
echo "PROJECT_NAME: $PROJECT_NAME"
echo "ENVIRONMENT: $ENVIRONMENT"
echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo "AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
