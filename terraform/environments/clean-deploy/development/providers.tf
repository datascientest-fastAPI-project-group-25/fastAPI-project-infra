# ================================
# Development Environment Provider Configuration
# ================================

# AWS provider configuration
provider "aws" {
  region = var.aws_region
}

# Data source to get EKS cluster information
data "aws_eks_cluster" "cluster" {
  name = "fastapi-project-eks-dev"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "fastapi-project-eks-dev"
}

# Configure Kubernetes provider with EKS cluster details
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name, "--region", var.aws_region]
  }
}

# Configure Helm provider with EKS cluster details
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name, "--region", var.aws_region]
    }
  }
}
