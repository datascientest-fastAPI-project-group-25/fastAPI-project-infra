#!/bin/bash

# Script to import and destroy the dev2 EKS cluster

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev2

echo "Importing and destroying EKS cluster: $PROJECT_NAME-eks-$ENVIRONMENT"
echo "Using AWS Region: $AWS_DEFAULT_REGION"

# Verify AWS credentials
echo "Verifying AWS credentials..."
aws sts get-caller-identity

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify AWS credentials"
    exit 1
fi

# Change to the terraform directory
cd terraform/environments/clean-deploy/delete-dev2-cluster

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Import the EKS cluster
echo "Importing EKS cluster..."
terraform import aws_eks_cluster.dev2_cluster fastapi-project-eks-dev2

# Plan the destruction
echo "Planning Terraform destruction..."
terraform plan -destroy -out=tfplan

# Apply the destruction
echo "Destroying EKS cluster (this may take 10-15 minutes)..."
terraform apply tfplan

echo "EKS cluster destruction initiated. This may take some time to complete."
