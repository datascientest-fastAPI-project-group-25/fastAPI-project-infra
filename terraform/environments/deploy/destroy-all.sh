#!/bin/bash

# Script to destroy all environments in reverse sequence

# Destroy production environment
echo "Destroying production environment..."
cd production
terraform destroy -var-file=terraform.tfvars -auto-approve
cd ..

# Wait for production environment to be destroyed
echo "Waiting for production environment to be destroyed..."
sleep 60

# Destroy staging environment
echo "Destroying staging environment..."
cd staging
terraform destroy -var-file=terraform.tfvars -auto-approve
cd ..

# Wait for staging environment to be destroyed
echo "Waiting for staging environment to be destroyed..."
sleep 60

# Destroy development environment
echo "Destroying development environment..."
cd development
terraform destroy -var-file=terraform.tfvars -auto-approve
cd ..

echo "All environments destroyed successfully!"
