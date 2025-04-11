# Development Environment Configuration

terraform {
  # Using local backend for testing
  backend "local" {}
}

# Configure providers that will be initialized after resources are created
# Note: We're using a workaround for the cycle dependency issue
# by setting placeholder values for the kubernetes provider
provider "kubernetes" {
  host                   = "https://localhost:8080"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 # Placeholder, will be replaced
  cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1USXhOekUwTWpnd05Gb1hEVEk1TVRJeE5ERTBNamd3TkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTlZoCnFjRUNtV3dqRW9hbGlqNXpEbVVybDFUUmRGYkRqYlNhWWV5akE0MG9HQzJTUlgrb3V0L0tOOVlTMTR5TDRJMmgKbGNxNXpTZ2xYUGsxUHN3ZnZEZkZMUEJtMkJlVmRmUXFhOGJkbXM3bHNVOWY0T01aQ0N4TXI0ZHpTNXZLNXRkNQpVcGNZcEhkS0JYNnhiUmhkTGZVdlBEZnlYZWZJTFNVNDdEcXZ3ZnhxNlpwZFZ3TmRUYmVpbzVDWk1UeGVjUlRuCnJsQlRpTnVaTk1qYnVUTzZ1aXJ5cVc2WVZYcUlRWGJCWkFyUG1zSUxvR0dLUXZrK0JpTjZqeXdCZXZPMkVDZEUKWUxMWFBmRnEzcnVzTUJlWlZ0QjBodEJDT3JHMHJQWVpHaXJvVlFhMlVFNHVsQmJEcXFrQ1hYTDlBK0dTcUJZUQpnbGRQRnJrQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3CkRRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFGU0MrYmJHaVhLK1l5MzZ0OEdXRlUwZkd1UEMvVWtlWVVsUHhNY3oKTmtNK0RPd0ZWdlFSZjJDRUw0bGhMNWVkTU1RSXNuZnJ1bGZIL1BFaFRVaEpqVzRlTjhNR0kvMm9iaDZUMm1XNQpYR0JxZW9WQ0JRMFVqMnRtS3VBQlgvb2ZiMWdLbStYRnJSWS9PbWVTWnhDTDdYc0ZLb2ZYYzRrQ0I5ZlNIOWlmCnJqQlpIUmJJRXZhMUZJUDZmZXYwM0JhZVpZTjJUTGpyVmhCNGhiQlBYaXlLWWI5c3BrZEh2bGZCUUFSSzZYa1YKRjJzMGlXQ2pKSDhXZ3FzQVJNVFpyOUZ5ZEMvV1hGd2FNL1dKYXFMTnJQYXhGQlJnVFRrR09WQzZIYnNFb0dRVgpYcUVOaDJDdlB1ZUF0aFhsRlJJMHNTQXZOTW1FRXJLR0pXMD0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=") # Placeholder
  token                  = "placeholder"
}

provider "helm" {
  kubernetes {
    host                   = "https://localhost:8080"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 # Placeholder, will be replaced
    cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1USXhOekUwTWpnd05Gb1hEVEk1TVRJeE5ERTBNamd3TkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTlZoCnFjRUNtV3dqRW9hbGlqNXpEbVVybDFUUmRGYkRqYlNhWWV5akE0MG9HQzJTUlgrb3V0L0tOOVlTMTR5TDRJMmgKbGNxNXpTZ2xYUGsxUHN3ZnZEZkZMUEJtMkJlVmRmUXFhOGJkbXM3bHNVOWY0T01aQ0N4TXI0ZHpTNXZLNXRkNQpVcGNZcEhkS0JYNnhiUmhkTGZVdlBEZnlYZWZJTFNVNDdEcXZ3ZnhxNlpwZFZ3TmRUYmVpbzVDWk1UeGVjUlRuCnJsQlRpTnVaTk1qYnVUTzZ1aXJ5cVc2WVZYcUlRWGJCWkFyUG1zSUxvR0dLUXZrK0JpTjZqeXdCZXZPMkVDZEUKWUxMWFBmRnEzcnVzTUJlWlZ0QjBodEJDT3JHMHJQWVpHaXJvVlFhMlVFNHVsQmJEcXFrQ1hYTDlBK0dTcUJZUQpnbGRQRnJrQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3CkRRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFGU0MrYmJHaVhLK1l5MzZ0OEdXRlUwZkd1UEMvVWtlWVVsUHhNY3oKTmtNK0RPd0ZWdlFSZjJDRUw0bGhMNWVkTU1RSXNuZnJ1bGZIL1BFaFRVaEpqVzRlTjhNR0kvMm9iaDZUMm1XNQpYR0JxZW9WQ0JRMFVqMnRtS3VBQlgvb2ZiMWdLbStYRnJSWS9PbWVTWnhDTDdYc0ZLb2ZYYzRrQ0I5ZlNIOWlmCnJqQlpIUmJJRXZhMUZJUDZmZXYwM0JhZVpZTjJUTGpyVmhCNGhiQlBYaXlLWWI5c3BrZEh2bGZCUUFSSzZYa1YKRjJzMGlXQ2pKSDhXZ3FzQVJNVFpyOUZ5ZEMvV1hGd2FNL1dKYXFMTnJQYXhGQlJnVFRrR09WQzZIYnNFb0dRVgpYcUVOaDJDdlB1ZUF0aFhsRlJJMHNTQXZOTW1FRXJLR0pXMD0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=") # Placeholder
    token                  = "placeholder"
  }
}

# Create VPC using our custom module
module "vpc" {
  source       = "../../modules/vpc"
  aws_region   = var.aws_region
  environment  = "development"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
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
  instance_types  = var.eks_node_group_instance_types
  desired_size    = var.eks_node_group_desired_size
  min_size        = var.eks_node_group_min_size
  max_size        = var.eks_node_group_max_size

  depends_on = [module.vpc, module.security]
}

# Kubernetes providers are configured at the top of the file

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
  source                                 = "../../modules/argo"
  environment                            = "development"
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
  source               = "../../modules/external-secrets"
  project_name         = var.project_name
  environment          = "development"
  region               = var.aws_region
  eks_oidc_provider    = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn

  depends_on = [module.eks]
}

# Configure GitHub Container Registry Access
module "ghcr_access" {
  source          = "../../modules/ghcr-access"
  github_username = var.github_username
  github_token    = var.github_token
  eks_role_arn    = module.eks.worker_iam_role_arn

  depends_on = [module.eks, module.k8s_resources]
}
