# ================================
# Root main.tf for Infra Repo
# ================================

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "fastapi-project-terraform-state-575977136211"
    key            = "fastapi/infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-test"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "fastapi-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "fastapi-eks"
  cluster_version = "1.27"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
  values     = [file("argocd-values.yaml")]
}

resource "kubernetes_manifest" "argocd_app" {
  manifest = yamldecode(file("argocd-app.yaml"))
}
