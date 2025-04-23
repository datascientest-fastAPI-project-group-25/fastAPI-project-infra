#!/bin/bash
# Script to test the Terraform workflow locally using act

# Ensure we're in the repository root
cd "$(git rev-parse --show-toplevel)" || exit 1

echo "Testing Terraform workflow locally using act"
echo "============================================"

# Function to clean up after tests
cleanup() {
  echo "Cleaning up..."
  rm -f .github/workflows/terraform.yml.bak
  echo "Done."
}

# Backup the original workflow file
cp .github/workflows/terraform.yml .github/workflows/terraform.yml.bak

echo "1. Testing PR validation (should run checks but not deployment)"
echo "-------------------------------------------------------------"
act pull_request -W .github/workflows/terraform.yml \
  --secret-file .env.act \
  --eventpath tests/act/pr-event.json

echo
echo "2. Testing push to main from PR merge (should run deployment)"
echo "-----------------------------------------------------------"
act push -W .github/workflows/terraform.yml \
  --secret-file .env.act \
  --eventpath tests/act/pr-merge-event.json

echo
echo "3. Testing direct push to main (should NOT run deployment)"
echo "--------------------------------------------------------"
act push -W .github/workflows/terraform.yml \
  --secret-file .env.act \
  --eventpath tests/act/direct-push-event.json

# Restore the original workflow file
mv .github/workflows/terraform.yml.bak .github/workflows/terraform.yml

echo
echo "Tests completed. Check the output above to verify the behavior."