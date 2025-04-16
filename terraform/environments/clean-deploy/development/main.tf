# Development Environment Configuration

# Create VPC using our custom module
module "vpc" {
  source       = "../../../modules/vpc"
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# Create security groups for EKS access
module "security" {
  source              = "../../../modules/security"
  vpc_id              = module.vpc.vpc_id
  environment         = var.environment
  project_name        = var.project_name
  allowed_cidr_blocks = var.allowed_cidr_blocks

  depends_on = [module.vpc]
}

# Create EKS cluster using our custom module
module "eks" {
  source       = "../../../modules/eks"
  aws_region   = var.aws_region
  environment  = var.environment
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
