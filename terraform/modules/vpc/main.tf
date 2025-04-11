# VPC Module
# This module creates a VPC for the EKS cluster and related networking resources

# Create VPC using the AWS VPC module
module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "~> 5.0"
  name            = "${var.project_name}-vpc-${var.environment}"
  cidr            = var.vpc_cidr
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  # Enable NAT Gateway for private subnets
  enable_nat_gateway = true
  single_nat_gateway = true
  # Enable DNS support
  enable_dns_hostnames = true
  enable_dns_support   = true
  # Add tags to all resources
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
    Name        = "${var.project_name}-vpc-${var.environment}"
  }
  # Add specific tags to subnets for EKS
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                            = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb"                                     = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  }
}

# Create DB subnet group for RDS instances
resource "aws_db_subnet_group" "database" {
  name        = "${var.project_name}-db-subnet-group-${var.environment}"
  description = "Database subnet group for ${var.project_name} ${var.environment}"
  subnet_ids  = module.vpc.private_subnets

  tags = {
    Name        = "${var.project_name}-db-subnet-group-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}