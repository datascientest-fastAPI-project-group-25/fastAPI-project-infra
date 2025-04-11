# RDS Module
# This module creates an RDS PostgreSQL instance for the FastAPI application
# DB subnet group is now managed by the VPC module
# Security group is now managed by the security module
resource "random_password" "postgres" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "postgres_credentials" {
  name        = "${var.environment}/postgres/credentials"
  description = "PostgreSQL credentials for ${var.environment} environment"
  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "postgres_credentials" {
  secret_id = aws_secretsmanager_secret.postgres_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.postgres.result
    host     = aws_db_instance.postgres.address
    port     = 5432
    database = var.db_name
  })
}

resource "aws_db_instance" "postgres" {
  identifier              = "fastapi-${var.environment}"
  engine                  = "postgres"
  engine_version          = var.postgres_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_type            = "gp3"
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.postgres.result
  parameter_group_name    = "default.postgres14"
  skip_final_snapshot     = var.environment != "production"
  deletion_protection     = var.environment == "production"
  backup_retention_period = var.environment == "production" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "Sun:04:00-Sun:05:00"
  multi_az                = var.environment == "production"
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [var.rds_security_group_id]

  tags = {
    Name        = "fastapi-${var.environment}"
    Environment = var.environment
  }
}
