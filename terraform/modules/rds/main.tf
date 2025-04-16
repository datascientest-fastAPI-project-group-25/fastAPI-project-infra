resource "aws_db_subnet_group" "default" {
  name        = "${var.project_name}-rds-subnet-group-${var.environment}"
  description = "Subnet group for ${var.project_name} RDS instance in ${var.environment} environment"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-rds-subnet-group-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

resource "aws_db_parameter_group" "default" {
  name        = "${var.project_name}-rds-parameter-group-${var.environment}"
  family      = "postgres14"
  description = "Parameter group for ${var.project_name} RDS instance in ${var.environment} environment"

  tags = {
    Name        = "${var.project_name}-rds-parameter-group-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

resource "aws_db_instance" "default" {
  identifier         = "${var.project_name}-rds-${var.environment}"
  instance_class     = var.instance_class
  engine             = "postgres"
  engine_version     = "14.10"
  db_subnet_group_name = aws_db_subnet_group.default.name
  parameter_group_name = aws_db_parameter_group.default.name
  skip_final_snapshot = true
  deletion_protection = var.environment == "production" ? true : false

  tags = {
    Name        = "${var.project_name}-rds-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}
