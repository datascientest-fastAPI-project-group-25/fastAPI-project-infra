#!/bin/bash

# Script to reorganize the Terraform directory structure
# This script will:
# 1. Move root terraform files to a legacy directory
# 2. Update scripts to use the clean-deploy approach
# 3. Clean up unnecessary files and directories

echo "Starting Terraform reorganization..."

# Create a legacy directory for the root terraform files
echo "Creating legacy directory..."
mkdir -p terraform/legacy

# Move root terraform files to the legacy directory
echo "Moving root terraform files to legacy directory..."
mv terraform/*.tf terraform/legacy/
mv terraform/terraform.tfvars terraform/legacy/

# Update deployment scripts to use the clean-deploy approach
echo "Updating deployment scripts..."

# Update deploy-infra.sh
echo "Updating deploy-infra.sh..."
sed -i 's|cd terraform|cd terraform/environments/clean-deploy/development|g' scripts/deployment/deploy-infra.sh
sed -i 's|key=fastapi/infra/terraform.tfstate|key=fastapi/infra/development/terraform.tfstate|g' scripts/deployment/deploy-infra.sh
sed -i 's|dynamodb_table=terraform-state-lock-test|dynamodb_table=terraform-state-lock-dev|g' scripts/deployment/deploy-infra.sh

# Update deploy-targeted.sh
echo "Updating deploy-targeted.sh..."
sed -i 's|cd terraform|cd terraform/environments/clean-deploy/development|g' scripts/deployment/deploy-targeted.sh
sed -i 's|key=fastapi/infra/terraform.tfstate|key=fastapi/infra/development/terraform.tfstate|g' scripts/deployment/deploy-targeted.sh
sed -i 's|dynamodb_table=terraform-state-lock-test|dynamodb_table=terraform-state-lock-dev|g' scripts/deployment/deploy-targeted.sh

# Update deploy.sh
echo "Updating deploy.sh..."
sed -i 's|cd terraform|cd terraform/environments/clean-deploy/development|g' scripts/deployment/deploy.sh
sed -i 's|key=fastapi/infra/terraform.tfstate|key=fastapi/infra/development/terraform.tfstate|g' scripts/deployment/deploy.sh
sed -i 's|dynamodb_table=terraform-state-lock-test|dynamodb_table=terraform-state-lock-dev|g' scripts/deployment/deploy.sh

# Create a README.md file in the legacy directory explaining its purpose
echo "Creating README.md in legacy directory..."
cat > terraform/legacy/README.md << EOF
# Legacy Terraform Configuration

This directory contains the original Terraform configuration that was previously in the root terraform directory.
It has been moved here as part of a reorganization to use the clean-deploy approach in terraform/environments/clean-deploy/development.

These files are kept for reference purposes and are no longer actively used.
All deployment scripts have been updated to use the clean-deploy approach.
EOF

# Create a README.md file in the root terraform directory explaining the structure
echo "Creating README.md in root terraform directory..."
cat > terraform/README.md << EOF
# Terraform Configuration

This directory contains the Terraform configuration for the FastAPI project infrastructure.

## Directory Structure

- **environments/**: Contains environment-specific Terraform configurations
  - **clean-deploy/**: Contains the clean deployment approach configurations
    - **development/**: Development environment configuration
    - **staging/**: Staging environment configuration (to be implemented)
    - **production/**: Production environment configuration (to be implemented)
  - **argocd-deploy-clean/**: Contains ArgoCD-specific deployment configuration
- **modules/**: Contains reusable Terraform modules
  - **argo/**: ArgoCD deployment module
  - **eks/**: EKS cluster module
  - **external-secrets/**: External Secrets Operator module
  - **ghcr-access/**: GitHub Container Registry access module
  - **iam/**: IAM roles and policies module
  - **k8s-resources/**: Kubernetes resources module
  - **oidc/**: OIDC authentication module
  - **security/**: Security groups module
  - **vpc/**: VPC module
- **legacy/**: Contains the original Terraform configuration (kept for reference)

## Deployment

Use the scripts in the scripts/deployment directory to deploy the infrastructure.
The main deployment script is scripts/deployment/deploy-with-oidc.sh, which uses OIDC authentication.
EOF

echo "Terraform reorganization completed!"
echo "Please review the changes and commit them."
