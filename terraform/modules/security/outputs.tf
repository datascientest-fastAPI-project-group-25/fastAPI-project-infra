# Outputs
output "public_security_group_id" {
  description = "ID of the EKS public security group"
  value       = aws_security_group.eks_public.id
}

output "private_security_group_id" {
  description = "ID of the EKS private security group"
  value       = aws_security_group.eks_private.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = var.create_rds_sg ? aws_security_group.rds[0].id : null
}