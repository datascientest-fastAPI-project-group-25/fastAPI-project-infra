# Outputs
output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "The OIDC Provider URL without the https:// prefix"
  value       = module.eks.oidc_provider
}

output "worker_iam_role_arn" {
  description = "ARN of the EKS worker IAM role"
  value       = module.eks.worker_iam_role_arn
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_id
}
