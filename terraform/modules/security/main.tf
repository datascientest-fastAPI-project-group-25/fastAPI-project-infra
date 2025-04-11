# Security Module
# This module creates security groups for EKS access
# Create a public security group for EKS access
resource "aws_security_group" "eks_public" {
  name        = "${var.project_name}-eks-public-${var.environment}"
  description = "Public security group for EKS access"
  vpc_id      = var.vpc_id

  # Allow inbound traffic to the Kubernetes API server
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow HTTPS access to the Kubernetes API server"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-eks-public-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

# Create a private security group for EKS internal communication
resource "aws_security_group" "eks_private" {
  name        = "${var.project_name}-eks-private-${var.environment}"
  description = "Private security group for EKS internal communication"
  vpc_id      = var.vpc_id

  # Allow all internal traffic within the security group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true # Allow traffic from the same security group
    description = "Allow all internal traffic"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-eks-private-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

# Create a security group for RDS access
resource "aws_security_group" "rds" {
  count       = var.create_rds_sg ? 1 : 0
  name        = "${var.project_name}-rds-${var.environment}"
  description = "Security group for RDS access"
  vpc_id      = var.vpc_id

  # Allow PostgreSQL traffic from the EKS private security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_private.id]
    description     = "Allow PostgreSQL traffic from EKS"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-rds-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

