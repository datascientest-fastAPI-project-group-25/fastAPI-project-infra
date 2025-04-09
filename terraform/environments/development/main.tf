# Development Environment Configuration

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
    key            = "fastapi/infra/development/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-test"
  }
}

# Create VPC using our custom module
module "vpc" {
  source       = "../../modules/vpc"
  aws_region   = var.aws_region
  environment  = "development"
  project_name = var.project_name
  cidr_block   = var.vpc_cidr
}

# Create security groups for EKS access
module "security" {
  source              = "../../modules/security"
  vpc_id              = module.vpc.vpc_id
  environment         = "development"
  project_name        = var.project_name
  allowed_cidr_blocks = var.allowed_cidr_blocks

  depends_on = [module.vpc]
}

# Create EKS cluster using our custom module
module "eks" {
  source       = "../../modules/eks"
  aws_region   = var.aws_region
  environment  = "development"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  security_group_ids = [
    module.security.public_security_group_id,
    module.security.private_security_group_id
  ]
  cluster_version = var.eks_cluster_version
  node_group_instance_types = var.eks_node_group_instance_types
  node_group_desired_size = var.eks_node_group_desired_size
  node_group_min_size = var.eks_node_group_min_size
  node_group_max_size = var.eks_node_group_max_size

  depends_on = [module.vpc, module.security]
}

# Configure kubectl to use the EKS cluster
data "aws_eks_cluster" "cluster" {
  name = "${var.project_name}-eks-development"
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${var.project_name}-eks-development"
  depends_on = [module.eks]
}

# Configure Kubernetes and Helm providers
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Deploy Kubernetes resources using our custom module
module "k8s_resources" {
  source          = "../../modules/k8s-resources"
  environment     = "development"
  github_username = var.github_username
  github_token    = var.github_token
  db_username     = var.db_username
  db_password     = var.db_password
  db_name         = var.db_name

  depends_on = [module.eks]
}

# Deploy ArgoCD using our custom module
module "argocd" {
  source                              = "../../modules/argo"
  environment                         = "development"
  project_name                        = var.project_name
  eks_cluster_endpoint                = module.eks.cluster_endpoint
  eks_cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  eks_auth_token                      = data.aws_eks_cluster_auth.cluster.token
  github_org                          = var.github_org
  release_repo                        = var.release_repo

  depends_on = [module.eks, module.k8s_resources]
}
