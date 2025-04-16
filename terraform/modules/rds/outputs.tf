output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_rds_cluster_instance.default.id
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_rds_cluster.default.endpoint
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_rds_cluster.default.endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_rds_cluster.default.database_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_rds_cluster.default.master_username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_rds_cluster.default.port
}

output "db_subnet_group_id" {
  description = "The ID of the DB subnet group"
  value       = aws_db_subnet_group.default.id
}

output "db_security_group_id" {
  description = "The ID of the security group created for the RDS instance"
  value       = aws_security_group.rds.id
}

output "db_parameter_group_id" {
  description = "The ID of the DB parameter group"
  value       = aws_db_parameter_group.default.id
}