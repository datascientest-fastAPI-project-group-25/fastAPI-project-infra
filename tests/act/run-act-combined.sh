#!/bin/bash

# This script runs Act with either normal or mock AWS functionality for local testing

# Default ENV
ENV=${ENV:-local-test}

# Default mode (normal or mock)
MODE=${1:-normal}
WORKFLOW_JOB=${2:-bootstrap}

# Load environment variables using the central script
. "$(dirname "${BASH_SOURCE[0]}")/../../bootstrap/scripts/load-env.sh"

# Check if Act is installed
if ! command -v act &> /dev/null; then
    echo "Error: Act is not installed. Please install it first."
    echo "See: https://github.com/nektos/act#installation"
    exit 1
fi

# Determine the correct .env file based on ENV_TYPE
ENV_FILE=""
case "$ENV_TYPE" in
  test)
    ENV_FILE="${PWD}/tests/.env.test"
    ;;
  local-test)
    ENV_FILE="${PWD}/tests/.env.local-test"
    ;;
  *)
    # Default to local-test for act
    ENV_FILE="${PWD}/tests/.env.local-test"
    ;;
esac

# Check if the required test env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file '$ENV_FILE' not found for ENV_TYPE='$ENV_TYPE'"
  echo "Please create it based on an example (e.g., tests/.env.local-test.example)"
  exit 1
fi

# Handle different modes
if [ "$MODE" = "mock" ]; then
    # Create a temporary directory for mock AWS scripts
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT

    # Create mock AWS CLI script
    cat > "$TEMP_DIR/aws" << 'EOF'
#!/bin/bash

# Mock AWS CLI for Act
echo "MOCK AWS CLI: $@"

# Use localstack endpoint for all AWS CLI commands
if [[ "$1" == "sts" && "$2" == "get-caller-identity" ]]; then
    # For get-caller-identity, use localstack endpoint
    aws --endpoint-url=http://localhost:4566 sts get-caller-identity
    exit $?
elif [[ "$1" == "s3api" && "$2" == "head-bucket" ]]; then
    # For head-bucket, use localstack endpoint
    aws --endpoint-url=http://localhost:4566 s3api head-bucket --bucket "${4}"
    exit $?
elif [[ "$1" == "s3api" && "$2" == "create-bucket" ]]; then
    # For create-bucket, use localstack endpoint
    aws --endpoint-url=http://localhost:4566 s3api create-bucket --bucket "${4}" --region us-east-1
    exit $?
elif [[ "$1" == "dynamodb" && "$2" == "create-table" ]]; then
    # For create-table, use localstack endpoint
    aws --endpoint-url=http://localhost:4566 dynamodb create-table --table-name "${4}" --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST
    exit $?
elif [[ "$1" == "iam" && "$2" == "get-role" ]]; then
    # For get-role, use localstack endpoint
    aws --endpoint-url=http://localhost:4566 iam get-role --role-name "${4}"
    exit $?
else
    # For all other commands, use localstack endpoint
    aws --endpoint-url=http://localhost:4566 "$@"
    exit $?
fi
EOF

    chmod +x "$TEMP_DIR/aws"

    # Create mock terraform script
    cat > "$TEMP_DIR/terraform" << 'EOF'
#!/bin/bash

# Mock Terraform for Act
echo "MOCK Terraform: $@"

# Handle specific commands
if [[ "$1" == "init" ]]; then
    echo "MOCK: Terraform initialized successfully"
elif [[ "$1" == "apply" ]]; then
    echo "MOCK: Terraform apply completed successfully"
elif [[ "$1" == "--version" ]]; then
    echo "Terraform v1.5.7 (mock)"
fi

# Default success
exit 0
EOF

    chmod +x "$TEMP_DIR/terraform"

    # Start localstack if it's not already running
    echo "Checking if LocalStack is running..."
    if ! docker ps | grep -q localstack; then
        echo "Starting LocalStack..."
        docker run -d --name localstack -p 4566:4566 -p 4571:4571 localstack/localstack
        echo "Waiting for LocalStack to be ready..."
        sleep 10

        # Initialize localstack
        echo "Initializing LocalStack..."
        cd ../../bootstrap/environments/localstack && ./init-localstack.sh
        cd -
    fi

    echo "Running act for mock workflow..."
    # Use the dedicated .env file for local testing
    PATH="$TEMP_DIR:$PATH" ACT=true act push \
    -W .github/workflows/ \
    --container-architecture linux/amd64 \
    --job ${WORKFLOW_JOB:-mock_job} \
    --secret-file "$ENV_FILE" \
    --env ACT=true \
    --env ENV="$ENV" \
    --env ENV_TYPE="$ENV_TYPE" \
    --env ENV_STAGE="$ENV_STAGE"
else
    # Normal mode - determine workflow file based on provided argument or default
    WORKFLOW_FILE=""

    case "$WORKFLOW_JOB" in
      bootstrap)
        WORKFLOW_FILE=".github/workflows/bootstrap.yml"
        ;;
      terraform)
        WORKFLOW_FILE=".github/workflows/terraform.yml"
        ;;
      *)
        echo "Error: Unknown workflow job '$WORKFLOW_JOB'. Use 'bootstrap' or 'terraform'."
        exit 1
        ;;
    esac

    echo "Running act for job '$WORKFLOW_JOB' using workflow '$WORKFLOW_FILE' and secrets from '$ENV_FILE'..."

    # Run act with specified workflow, job, and secrets
    act push \
      -W $(dirname "$WORKFLOW_FILE") \
      --container-architecture linux/amd64 \
      --job $WORKFLOW_JOB \
      --secret-file "$ENV_FILE" \
      --env ACT=true \
      --env ENV="$ENV" \
      --env ENV_TYPE="$ENV_TYPE" \
      --env ENV_STAGE="$ENV_STAGE"
fi