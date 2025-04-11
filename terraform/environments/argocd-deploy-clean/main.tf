# ArgoCD Deployment Configuration

terraform {
  # Using local backend for development
  backend "local" {}
}

# AWS provider configuration
provider "aws" {
  region = var.aws_region
}

# Get data about the existing EKS cluster
data "aws_eks_cluster" "cluster" {
  name = "fastapi-project-development"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "fastapi-project-development"
}

# Configure Kubernetes provider with EKS cluster details
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Configure Helm provider with EKS cluster details
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Deploy ArgoCD using our custom module
module "argocd" {
  source                                 = "../../modules/argo"
  environment                            = "development"
  project_name                           = var.project_name
  eks_cluster_endpoint                   = data.aws_eks_cluster.cluster.endpoint
  eks_cluster_certificate_authority_data = data.aws_eks_cluster.cluster.certificate_authority[0].data
  eks_auth_token                         = data.aws_eks_cluster_auth.cluster.token
  github_org                             = var.github_org
  release_repo                           = var.release_repo
}
