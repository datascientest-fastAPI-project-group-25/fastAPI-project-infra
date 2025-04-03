#!/bin/bash

# This script runs Act with the correct parameters for local testing

# Check if .env.local-test exists
if [ ! -f ".env.local-test" ]; then
  echo "Error: .env.local-test file not found"
  exit 1
fi

# Load secrets from .env.local-test
source .env.local-test

# Run Act with the bootstrap job
echo "Running bootstrap job with Act..."
act -j bootstrap -W .github/workflows/terraform-bootstrap.yml \
  --secret AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  --secret AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  --secret AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID" \
  --secret AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION"
