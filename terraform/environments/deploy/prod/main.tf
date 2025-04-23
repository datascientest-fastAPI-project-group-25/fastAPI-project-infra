# Production Environment Configuration

terraform {
  # Using local backend for production
  backend "local" {}
}

# AWS provider configuration
provider "aws" {
  region = var.aws_region
}

# Create VPC using our custom module
module "vpc" {
  source       = "../../../modules/vpc"
  aws_region   = var.aws_region
  environment  = "prod"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# Create security groups for EKS access
module "security" {
  source              = "../../../modules/security"
  vpc_id              = module.vpc.vpc_id
  environment         = "prod"
  project_name        = var.project_name
  allowed_cidr_blocks = var.allowed_cidr_blocks
  # NOTE: allowed_cidr_blocks should be restricted in production

  depends_on = [module.vpc]
}

# Create EKS cluster using our custom module
module "eks" {
  source       = "../../../modules/eks"
  aws_region   = var.aws_region
  environment  = "prod"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  security_group_ids = [
    module.security.public_security_group_id,
    module.security.private_security_group_id
  ]
  cluster_version = var.eks_cluster_version
  instance_types  = var.eks_node_group_instance_types
  desired_size    = var.eks_node_group_desired_size
  min_size        = var.eks_node_group_min_size
  max_size        = var.eks_node_group_max_size

  depends_on = [module.vpc, module.security]
}

# Create RDS instance for production
module "rds" {
  source                 = "../../../modules/rds"
  project_name           = var.project_name
  environment            = "prod"
  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  eks_security_group_ids = [module.security.private_security_group_id]
  rds_security_group_id  = module.security.rds_security_group_id
  db_username            = var.db_username
  db_password            = var.db_password
  db_name                = var.db_name
  instance_class         = var.rds_instance_class
  allocated_storage      = var.rds_allocated_storage
  max_allocated_storage  = var.rds_max_allocated_storage
  multi_az               = true # Enable high availability for production

  depends_on = [module.vpc, module.security]
}

# Configure Kubernetes provider with EKS cluster details
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

# Configure Helm provider with EKS cluster details
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}

# Configure GHCR authentication for pulling images
module "ghcr_auth" {
  source                         = "../../../modules/ghcr-secret"
  environment                    = "prod"
  namespaces                     = ["fastapi-helm-prod"] # Match k8s_resources namespace
  github_org                     = var.github_org
  machine_user_token_secret_name = "github/machine-user-token"

  depends_on = [module.eks]
}

# Deploy Kubernetes resources using our custom module
module "k8s_resources" {
  source          = "../../../modules/k8s-resources"
  environment     = "prod"
  namespace       = "fastapi-helm-prod" # Keep namespace consistent
  db_username     = var.db_username
  db_password     = var.db_password
  db_name         = var.db_name
  use_external_db = true
  db_host         = module.rds.db_instance_address
  db_port         = module.rds.db_instance_port

  depends_on = [module.eks, module.rds]
}

# Deploy ArgoCD using our custom module
module "argocd" {
  source                                 = "../../../modules/argo"
  environment                            = "prod"
  project_name                           = var.project_name
  eks_cluster_endpoint                   = module.eks.cluster_endpoint
  eks_cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  eks_auth_token                         = ""
  github_org                             = var.github_org
  release_repo                           = var.release_repo

  depends_on = [module.eks, module.k8s_resources]
}

# Deploy External Secrets Operator
module "external_secrets" {
  source                = "../../../modules/external-secrets"
  project_name          = var.project_name
  environment           = "prod"
  region                = var.aws_region
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn

  depends_on = [module.eks]
}

# Configure GitHub Actions OIDC
module "github_actions_oidc" {
  source      = "../../../modules/github-actions-oidc"
  environment = "prod"
  github_org  = var.github_org
  github_repo = var.github_repo       # Add missing variable
  namespaces  = ["fastapi-helm-prod"] # Match k8s_resources namespace

  depends_on = [module.eks]
}
