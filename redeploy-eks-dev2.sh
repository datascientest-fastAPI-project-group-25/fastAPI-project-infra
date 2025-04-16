#!/bin/bash

# Script to redeploy EKS cluster with OIDC authentication
# This script is designed to work around the for_each issue in the EKS module

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=575977136211
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev2

echo "Redeploying EKS cluster with OIDC authentication..."
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"
echo "Environment: $ENVIRONMENT"

# Verify AWS credentials
echo "Verifying AWS credentials..."
aws sts get-caller-identity

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify AWS credentials"
    exit 1
fi

# Navigate to the development environment directory
cd terraform/environments/clean-deploy/development

# Remove existing Terraform files to avoid conflicts
rm -f main.tf providers.tf

# Update backend.tf to use local backend
echo "Updating backend configuration to use local backend..."
cat > backend.tf << EOF
# Terraform backend and provider configuration
terraform {
  # Using local backend for development
  backend "local" {
    path = "terraform-dev2.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
EOF

# Create a simplified main.tf file for the dev2 environment
echo "Creating simplified Terraform configuration..."
cat > main-dev2.tf << EOF
# Simplified Development Environment Configuration for dev2

# Create VPC using our custom module
module "vpc" {
  source       = "../../../modules/vpc"
  aws_region   = var.aws_region
  environment  = "$ENVIRONMENT"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# Create security groups for EKS access
module "security" {
  source              = "../../../modules/security"
  vpc_id              = module.vpc.vpc_id
  environment         = "$ENVIRONMENT"
  project_name        = var.project_name
  allowed_cidr_blocks = var.allowed_cidr_blocks

  depends_on = [module.vpc]
}

# Create EKS cluster using our custom module
module "eks" {
  source       = "../../../modules/eks"
  aws_region   = var.aws_region
  environment  = "$ENVIRONMENT"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  security_group_ids = [
    module.security.public_security_group_id,
    module.security.private_security_group_id
  ]
  node_security_group_id = module.security.node_security_group_id
  cluster_version = var.eks_cluster_version
  instance_types  = var.eks_node_group_instance_types
  desired_size    = var.eks_node_group_desired_size
  min_size        = var.eks_node_group_min_size
  max_size        = var.eks_node_group_max_size

  depends_on = [module.vpc, module.security]
}
EOF

# Initialize Terraform with local backend
echo "Initializing Terraform with local backend..."
terraform init -reconfigure

# Plan the deployment
echo "Planning Terraform deployment..."
terraform plan -out=tfplan

# Ask for confirmation before applying
echo "Ready to deploy EKS cluster. This will create:"
echo "1. VPC and Networking (Public and Private Subnets, Internet Gateway, NAT Gateway)"
echo "2. Security Groups (Public and Private Security Groups)"
echo "3. EKS Cluster (Control Plane and Node Groups)"
echo
read -p "Do you want to proceed with the deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment aborted."
    exit 1
fi

# Apply Terraform changes
echo "Applying Terraform changes (this may take 15-20 minutes)..."
terraform apply tfplan

# Configure kubectl to use the EKS cluster
echo "Configuring kubectl to use the EKS cluster..."
aws eks update-kubeconfig --name $PROJECT_NAME-eks-$ENVIRONMENT --region $AWS_DEFAULT_REGION

# Verify the cluster is working
echo "Verifying the cluster is working..."
kubectl get nodes

echo "EKS cluster deployed successfully!"
