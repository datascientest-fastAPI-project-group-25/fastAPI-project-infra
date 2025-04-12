# Development Environment Configuration

# Configure IAM resources for OIDC authentication
module "iam" {
  source           = "../../../modules/iam"
  environment      = "dev"
  project_name     = var.project_name
  aws_region       = var.aws_region
  github_org       = var.github_org
  state_bucket_name = "fastapi-project-terraform-state-575977136211"
  lock_table_name  = "terraform-state-lock"
}

# Create VPC using our custom module
module "vpc" {
  source       = "../../../modules/vpc"
  aws_region   = var.aws_region
  environment  = "dev2"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# Create security groups for EKS access
module "security" {
  source              = "../../../modules/security"
  vpc_id              = module.vpc.vpc_id
  environment         = "dev2"
  project_name        = var.project_name
  allowed_cidr_blocks = var.allowed_cidr_blocks

  depends_on = [module.vpc]
}

# Create EKS cluster using our custom module
module "eks" {
  source       = "../../../modules/eks"
  aws_region   = var.aws_region
  environment  = "dev2"
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

# Deploy Kubernetes resources using our custom module
module "k8s_resources" {
  source          = "../../../modules/k8s-resources"
  environment     = "dev2"
  github_username = var.github_username
  github_token    = var.github_token
  db_username     = var.db_username
  db_password     = var.db_password
  db_name         = var.db_name
  # Using in-cluster PostgreSQL for development
  use_external_db = false

  depends_on = [module.eks]
}

# Deploy ArgoCD using our custom module
module "argocd" {
  source                                 = "../../../modules/argo"
  environment                            = "dev2"
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
  source               = "../../../modules/external-secrets"
  project_name         = var.project_name
  environment          = "dev2"
  region               = var.aws_region
  eks_oidc_provider    = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn

  depends_on = [module.eks]
}

# Configure GitHub Container Registry Access with OIDC
module "ghcr_access" {
  source          = "../../../modules/ghcr-access"
  environment     = "dev2"
  github_org      = var.github_org
  github_username = var.github_username
  github_token    = var.github_token  # Kept as fallback
  eks_role_arn    = module.eks.worker_iam_role_arn  # Kept as fallback

  depends_on = [module.eks, module.k8s_resources]
}