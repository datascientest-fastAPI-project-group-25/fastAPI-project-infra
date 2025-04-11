#!/bin/bash

# Script to deploy all environments in sequence

# Check if the script is run with the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <github_token> <db_username> <db_password>"
    exit 1
fi

GITHUB_TOKEN=$1
DB_USERNAME=$2
DB_PASSWORD=$3

# Update secrets
echo "Updating secrets..."
./update-secrets.sh "$GITHUB_TOKEN" "$DB_USERNAME" "$DB_PASSWORD"

# Deploy development environment
echo "Deploying development environment..."
cd development
terraform init
terraform apply -var-file=terraform.tfvars -auto-approve
cd ..

# Wait for development environment to stabilize
echo "Waiting for development environment to stabilize..."
sleep 60

# Deploy staging environment
echo "Deploying staging environment..."
cd staging
terraform init
terraform apply -var-file=terraform.tfvars -auto-approve
cd ..

# Wait for staging environment to stabilize
echo "Waiting for staging environment to stabilize..."
sleep 60

# Deploy production environment
echo "Deploying production environment..."
cd production
terraform init
terraform apply -var-file=terraform.tfvars -auto-approve
cd ..

echo "All environments deployed successfully!"
