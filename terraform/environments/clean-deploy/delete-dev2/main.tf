# Terraform configuration to delete the dev2 EKS cluster

provider "aws" {
  region = "us-east-1"
}

# Data source to get information about the existing EKS cluster
data "aws_eks_cluster" "dev2" {
  name = "fastapi-project-eks-dev2"
}

# Module to delete the EKS cluster
module "eks" {
  source       = "../../../modules/eks"
  aws_region   = "us-east-1"
  environment  = "dev2"
  project_name = "fastapi-project"
  vpc_id       = data.aws_eks_cluster.dev2.vpc_config[0].vpc_id
  subnet_ids   = data.aws_eks_cluster.dev2.vpc_config[0].subnet_ids
  security_group_ids = []
  node_security_group_id = ""
  
  # Setting count to 0 to delete the resources
  desired_size = 0
  min_size     = 0
  max_size     = 0
}
