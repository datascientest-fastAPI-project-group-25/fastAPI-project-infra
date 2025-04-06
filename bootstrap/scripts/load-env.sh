#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
PROJECT_ROOT="${SCRIPT_DIR}/../.."

# Function to load env file
load_env() {
    local env_file=$1
    if [ -f "$env_file" ]; then
        echo "Loading environment from $env_file"
        # Use 'set -a' to export all variables defined in the file
        set -a
        source "$env_file"
        set +a
    else
        echo "Warning: $env_file not found"
    fi
}

# Determine environment type (e.g., aws, localstack) and stage (e.g., dev, test, prod)
# Default to localstack if ENV is not set or doesn't contain a known type
ENV_TYPE="localstack" # Default
ENV_STAGE="dev"      # Default

if [[ -n "$ENV" ]]; then
    if [[ "$ENV" == *"aws"* ]]; then
        ENV_TYPE="aws"
    elif [[ "$ENV" == *"localstack"* || "$ENV" == "dev" ]]; then # Treat 'dev' as localstack for backwards compatibility
        ENV_TYPE="localstack"
    elif [[ "$ENV" == "test" ]]; then
        ENV_TYPE="test"
    elif [[ "$ENV" == "local-test" ]]; then
        ENV_TYPE="local-test"
    fi

    # Extract stage if present (e.g., _dev, _prod)
    if [[ "$ENV" == *"_"* ]]; then
      ENV_STAGE=$(echo "$ENV" | cut -d'_' -f2)
    elif [[ "$ENV" == "test" || "$ENV" == "local-test" ]]; then
      ENV_STAGE="test"
    fi
fi

echo "Determined Environment Type: $ENV_TYPE, Stage: $ENV_STAGE"

# 1. Load base bootstrap config (always loaded)
BASE_ENV="${SCRIPT_DIR}/../.env.base"
load_env "$BASE_ENV"

# 2. Load environment-specific file
SPECIFIC_ENV_FILE=""
case "$ENV_TYPE" in
    aws)
        SPECIFIC_ENV_FILE="${SCRIPT_DIR}/../environments/aws/.env.aws"
        ;;
    localstack)
        SPECIFIC_ENV_FILE="${SCRIPT_DIR}/../environments/localstack/.env.local"
        ;;
    test)
        SPECIFIC_ENV_FILE="${PROJECT_ROOT}/tests/.env.test"
        ;;
    local-test)
        SPECIFIC_ENV_FILE="${PROJECT_ROOT}/tests/.env.local-test"
        ;;
    *)
        echo "Warning: Unknown environment type '$ENV_TYPE'. Falling back to localstack."
        SPECIFIC_ENV_FILE="${SCRIPT_DIR}/../environments/localstack/.env.local"
        ;;
esac

if [[ -n "$SPECIFIC_ENV_FILE" ]]; then
    load_env "$SPECIFIC_ENV_FILE"
else
    echo "Warning: Could not determine specific environment file for ENV='$ENV'"
fi

# 3. Load bootstrap specific (optional, overrides others)
BOOTSTRAP_ENV="${SCRIPT_DIR}/../.env.bootstrap"
load_env "$BOOTSTRAP_ENV"

# 4. Load deprecated .env file at root level for backward compatibility
ROOT_ENV="${PROJECT_ROOT}/.env"
if [ -f "$ROOT_ENV" ]; then
    echo "Warning: Using deprecated .env file at root level for backward compatibility"
    load_env "$ROOT_ENV"
fi

# Export the determined environment variables for use in calling scripts/makefiles
export ENV_TYPE
export ENV_STAGE

echo "Environment loading complete."

# Process environment variables
# Replace any ${VAR} or $VAR in the values
for var in $(env | grep -v '^_' | cut -d= -f1); do
    val=$(eval echo "\$$var")
    export $var="$val"
done

# Verify required variables
# For role-based authentication, AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are optional
# if AWS credentials are configured in ~/.aws/credentials
required_vars=(
    "AWS_DEFAULT_REGION"
    "AWS_ACCOUNT_ID"
    "PROJECT_NAME"
    "ENVIRONMENT"
)

# Check if we're using role-based authentication
if [ -z "$AWS_BOOTSTRAP_ROLE_NAME" ]; then
    # If not using role-based auth, AWS credentials are required
    required_vars+=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY")
else
    # If using role-based auth, check if AWS credentials are available
    # either from environment variables or AWS CLI configuration
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "Note: AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY not set in environment."
        echo "Checking AWS CLI configuration..."
        if ! aws sts get-caller-identity &>/dev/null; then
            echo "Error: No valid AWS credentials found. Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
            echo "or configure AWS CLI with credentials that can assume the role $AWS_BOOTSTRAP_ROLE_NAME."
            exit 1
        else
            echo "AWS CLI credentials found. Will use these to assume role $AWS_BOOTSTRAP_ROLE_NAME."
        fi
    fi
fi

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
