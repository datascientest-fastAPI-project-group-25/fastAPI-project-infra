output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.postgres.address
}

output "db_instance_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.postgres.port
}

output "db_instance_name" {
  description = "The name of the RDS instance"
  value       = aws_db_instance.postgres.db_name
}

output "db_instance_username" {
  description = "The username for the RDS instance"
  value       = aws_db_instance.postgres.username
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.postgres.id
}

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the database credentials"
  value       = aws_secretsmanager_secret.postgres_credentials.arn
}

output "db_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${aws_db_instance.postgres.username}:${random_password.postgres.result}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}
