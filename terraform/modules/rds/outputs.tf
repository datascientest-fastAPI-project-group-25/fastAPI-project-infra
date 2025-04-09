output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.this.port
}

output "db_instance_name" {
  description = "The name of the RDS instance"
  value       = aws_db_instance.this.db_name
}

output "db_instance_username" {
  description = "The username for the RDS instance"
  value       = aws_db_instance.this.username
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.this.id
}

output "db_security_group_id" {
  description = "The ID of the security group for the RDS instance"
  value       = aws_security_group.db.id
}

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${aws_db_instance.this.username}:${local.db_password}@${aws_db_instance.this.endpoint}/${aws_db_instance.this.db_name}"
  sensitive   = true
}
