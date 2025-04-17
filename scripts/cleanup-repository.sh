#!/bin/bash

# Script to clean up the repository by removing unnecessary files and directories
# This script will remove:
# 1. Leftover files from previous attempts (dev2, dev3, import, localstack, etc.)
# 2. Temporary files and directories
# 3. Unused scripts and configuration files

echo "Starting repository cleanup..."

# Remove specific files in the root directory that are no longer needed
echo "Removing unnecessary files from root directory..."
rm -f create-terraform-config.sh eks-admin-policy.json eks-policy.json patch.yaml

# Remove any leftover state files (except the main ones)
echo "Cleaning up Terraform state files..."
find terraform -name "*.tfstate*" -not -path "*/\.*" -not -path "*/development/terraform.tfstate*" -delete

# Remove any leftover import directories and files
echo "Removing import-related directories and files..."
find terraform -path "*/import*" -type d -exec rm -rf {} \; 2>/dev/null || true
find terraform -name "*import*" -type f -delete

# Remove any leftover dev2 directories and files
echo "Removing dev2-related directories and files..."
find terraform -path "*/dev2*" -type d -exec rm -rf {} \; 2>/dev/null || true
find terraform -name "*dev2*" -type f -delete

# Remove any leftover dev3 directories and files
echo "Removing dev3-related directories and files..."
find terraform -path "*/dev3*" -type d -exec rm -rf {} \; 2>/dev/null || true
find terraform -name "*dev3*" -type f -delete

# Remove any leftover localstack directories and files
echo "Removing localstack-related directories and files..."
find terraform -path "*/localstack*" -type d -exec rm -rf {} \; 2>/dev/null || true
find terraform -name "*localstack*" -type f -delete

# Remove any leftover delete directories and files
echo "Removing delete-related directories and files..."
find terraform -path "*/delete*" -type d -exec rm -rf {} \; 2>/dev/null || true
find terraform -name "*delete*" -type f -not -path "*/destroy*" -delete

# Remove any leftover simple directories and files
echo "Removing simple-related directories and files..."
find terraform -path "*/simple*" -type d -exec rm -rf {} \; 2>/dev/null || true
find terraform -name "*simple*" -type f -delete

# Clean up any empty directories
echo "Cleaning up empty directories..."
find terraform -type d -empty -delete

# Clean up any .terraform directories
echo "Cleaning up .terraform directories..."
find terraform -name ".terraform" -type d -exec rm -rf {} \; 2>/dev/null || true

# Clean up any .terraform.lock.hcl files
echo "Cleaning up .terraform.lock.hcl files..."
find terraform -name ".terraform.lock.hcl" -type f -delete

echo "Repository cleanup completed!"
echo "You may want to review the changes and commit them."
