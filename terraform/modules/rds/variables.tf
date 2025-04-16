variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the RDS instance will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}

variable "central_security_group_id" {
  description = "ID of the central security group to use"
  type        = string
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.small"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB"
  type        = number
  default     = 100
}}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.project_name}-rds-${var.environment}"
  engine                  = "aurora-postgresql"
  engine_version          = "14.10"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  deletion_protection     = var.environment == "production" ? true : false

  vpc_security_group_ids = [var.central_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = {
    Name        = "${var.project_name}-rds-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

resource "aws_rds_cluster_instance" "default" {
  identifier         = "${var.project_name}-rds-instance-${var.environment}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version

  tags = {
    Name        = "${var.project_name}-rds-instance-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}