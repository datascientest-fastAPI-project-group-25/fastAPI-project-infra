# EKS Module
# This module creates an EKS cluster

# Create EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-eks-${var.environment}"
  cluster_version = var.cluster_version
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id

  # Enable IAM Roles for Service Accounts
  enable_irsa = true

  # Configure cluster access
  cluster_endpoint_private_access      = true          # Set to true for private cluster
  cluster_endpoint_public_access       = true          # Set to true for public cluster
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # Set to your desired CIDR blocks

  # Security groups
  create_cluster_security_group = true
  create_node_security_group    = true

  # Use the security group from the security module
  node_security_group_id = var.node_security_group_id

  # Node groups configuration
  eks_managed_node_groups = {
    default = {
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
      instance_types = var.instance_types

      labels = {
        Environment = var.environment
      }

      tags = {
        Environment = var.environment
        Project     = var.project_name
        Terraform   = "true"
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}


