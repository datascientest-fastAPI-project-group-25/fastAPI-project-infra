#!/bin/bash

set -e

echo "Testing Docker environments..."

# Build Docker images
echo "Building Docker images..."
make docker-build

# Test Localstack environment
echo "Testing Localstack environment..."
make docker-localstack-bootstrap-dryrun

# Test AWS environment (if AWS credentials are available)
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ] && [ -n "$AWS_ACCOUNT_ID" ]; then
    echo "Testing AWS environment..."
    make docker-aws-bootstrap-dryrun
else
    echo "Skipping AWS environment test (AWS credentials not available)"
fi

# Clean up
echo "Cleaning up..."
make docker-clean

echo "Tests completed successfully!"