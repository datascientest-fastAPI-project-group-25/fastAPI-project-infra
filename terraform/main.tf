# ================================
# Root main.tf for Infra Repo
# ================================

provider "aws" {
  region = var.aws_region
}

terraform {
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
  }

  backend "s3" {
    bucket         = "fastapi-project-terraform-state-575977136211"
    key            = "fastapi/infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-test"
  }
}

# Create VPC using our custom module
module "vpc" {
  source      = "./modules/vpc"
  aws_region  = var.aws_region
  environment = var.environment
  project_name = "fastapi-project"
}

# Create security groups for EKS access
module "security" {
  source      = "./modules/security"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  project_name = "fastapi-project"
  allowed_cidr_blocks = ["0.0.0.0/0"]  # This should be restricted in production

  depends_on = [module.vpc]
}

# Create EKS cluster using our custom module
module "eks" {
  source       = "./modules/eks"
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = "fastapi-project"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  security_group_ids = [
    module.security.public_security_group_id,
    module.security.private_security_group_id
  ]

  #Explicitly define the IAM role for the EKS cluster

  depends_on = [module.vpc, module.security]
}

# Configure kubectl to use the EKS cluster
# These data sources will be available after the EKS cluster is created
# For now, we'll comment them out and uncomment them after the EKS cluster is created
# data "aws_eks_cluster" "cluster" {
#   name = "fastapi-project-eks-dev"
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = "fastapi-project-eks-dev"
# }

# These providers will be configured after the EKS cluster is created
# For now, we'll use empty providers
provider "kubernetes" {
  # Configuration will be added after EKS cluster is created
}

provider "helm" {
  # Configuration will be added after EKS cluster is created
}

# We'll deploy ArgoCD after the EKS cluster is created
# For now, we'll comment out the ArgoCD module
# module "argocd" {
#   source                              = "./modules/argo"
#   environment                         = var.environment
#   project_name                        = "fastapi-project"
#   eks_cluster_endpoint                = module.eks.cluster_endpoint
#   eks_cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
#   eks_auth_token                      = data.aws_eks_cluster_auth.cluster.token
#
#   depends_on = [module.eks]
# }