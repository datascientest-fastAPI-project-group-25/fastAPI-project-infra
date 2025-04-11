# Outputs
output "public_security_group_id" {
  description = "ID of the EKS public security group"
  value       = aws_security_group.eks_public.id
}

output "private_security_group_id" {
  description = "ID of the EKS private security group"
  value       = aws_security_group.eks_private.id
}