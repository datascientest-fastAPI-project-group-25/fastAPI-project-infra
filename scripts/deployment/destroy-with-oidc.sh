#!/bin/bash

# Script to destroy infrastructure using OIDC authentication

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=575977136211
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev2

echo "Destroying infrastructure in AWS using OIDC authentication..."
echo "Using AWS Account: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_DEFAULT_REGION"

# Verify AWS credentials
echo "Verifying AWS credentials..."
aws sts get-caller-identity

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify AWS credentials"
    exit 1
fi

# Change to the terraform directory
cd terraform/environments/clean-deploy/development

# Remove existing Terraform files to avoid conflicts
rm -f main-simple.tf

# Use the existing state file
echo "Using existing state file terraform-dev2.tfstate..."
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
EOF

# Create a main.tf file for the dev2 environment
echo "Creating main.tf for dev2 environment..."
cat > main.tf << EOF
# Development Environment Configuration for dev2

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

# Initialize Terraform with reconfigure flag
terraform init -reconfigure

# Destroy resources in reverse order
echo "Destroying EKS..."
terraform destroy -target=module.eks -auto-approve

echo "Destroying Security Groups..."
terraform destroy -target=module.security -auto-approve

echo "Destroying VPC..."
terraform destroy -target=module.vpc -auto-approve

echo "Infrastructure destroyed successfully!"
