#!/bin/bash

# This script runs Act with mock AWS functionality for local testing

# Check if Act is installed
if ! command -v act &> /dev/null; then
    echo "Error: Act is not installed. Please install it first."
    echo "See: https://github.com/nektos/act#installation"
    exit 1
fi

# Create a temporary directory for mock AWS scripts
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Create mock AWS CLI script
cat > "$TEMP_DIR/aws" << 'EOF'
#!/bin/bash

# Mock AWS CLI for Act
echo "MOCK AWS CLI: $@"

# Handle specific commands
if [[ "$1" == "s3api" && "$2" == "head-bucket" ]]; then
    echo "MOCK: Bucket does not exist"
    exit 1
elif [[ "$1" == "s3api" && "$2" == "create-bucket" ]]; then
    echo "MOCK: Bucket created successfully"
    exit 0
elif [[ "$1" == "dynamodb" && "$2" == "create-table" ]]; then
    echo "MOCK: DynamoDB table created successfully"
    exit 0
elif [[ "$1" == "iam" && "$2" == "get-role" ]]; then
    echo "MOCK: Role exists"
    echo '{"Role": {"Arn": "arn:aws:iam::123456789012:role/FastAPIProjectBootstrapInfraRole"}}'
    exit 0
elif [[ "$1" == "sts" && "$2" == "get-caller-identity" ]]; then
    echo '{"UserId": "MOCKUSERID", "Account": "123456789012", "Arn": "arn:aws:iam::123456789012:user/mock-user"}'
    exit 0
fi

# Default success
exit 0
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

# Run Act with the mock scripts in PATH
echo "Running Act with mock AWS and Terraform..."
PATH="$TEMP_DIR:$PATH" ACT=true act -j bootstrap -W .github/workflows/terraform-bootstrap.yml \
  --secret-file .env.local-test \
  --env ACT=true
