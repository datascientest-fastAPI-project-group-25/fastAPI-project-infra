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

# Print configuration (without sensitive data)
echo "Environment Configuration:"
echo "PROJECT_NAME: $PROJECT_NAME"
echo "ENVIRONMENT: $ENVIRONMENT"
echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo "AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"