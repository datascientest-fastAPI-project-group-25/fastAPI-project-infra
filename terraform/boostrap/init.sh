#!/bin/bash

# Default to local environment
ENV=${1:-local}

if [ "$ENV" == "local" ]; then
  echo "Initializing Terraform with LocalStack backend..."
  terraform init -reconfigure
elif [ "$ENV" == "aws" ]; then
  echo "Initializing Terraform with AWS S3 backend..."
  terraform init -reconfigure -backend=true -backend-config=backend.hcl
else
  echo "Unknown environment: $ENV"
  echo "Usage: ./init.sh [local|aws]"
  exit 1
fi
