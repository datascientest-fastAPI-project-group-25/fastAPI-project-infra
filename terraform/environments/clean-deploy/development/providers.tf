# ================================
# Development Environment Provider Configuration
# ================================

# AWS provider configuration
provider "aws" {
  region = var.aws_region
}

# Data source to get EKS cluster information
data "aws_eks_cluster" "cluster" {
  name = "fastapi-project-dev2"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "fastapi-project-dev2"
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
