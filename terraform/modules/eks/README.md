# EKS Module

This module creates an Amazon Elastic Kubernetes Service (EKS) cluster with managed node groups.

## Resources Created

1. **EKS Cluster**
   - Kubernetes control plane
   - IAM roles and policies
   - Security groups
   - Logging configuration

2. **Managed Node Groups**
   - Auto-scaling worker nodes
   - IAM roles and instance profiles
   - Security groups
   - Launch templates

3. **Add-ons**
   - Amazon VPC CNI
   - CoreDNS
   - kube-proxy

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  project_name      = var.project_name
  environment       = var.environment
  cluster_name      = "${var.project_name}-eks-${var.environment}"
  cluster_version   = var.eks_cluster_version
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnets
  instance_types    = var.eks_instance_types
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name (development, staging, production) | `string` | n/a | yes |
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| cluster_version | Kubernetes version to use for the EKS cluster | `string` | n/a | yes |
| vpc_id | ID of the VPC where the cluster will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the EKS cluster | `list(string)` | n/a | yes |
| instance_types | List of instance types for the EKS node group | `list(string)` | n/a | yes |
| desired_size | Desired number of worker nodes | `number` | `2` | no |
| min_size | Minimum number of worker nodes | `number` | `1` | no |
| max_size | Maximum number of worker nodes | `number` | `3` | no |
| disk_size | Disk size in GiB for worker nodes | `number` | `50` | no |
| enable_cluster_autoscaler | Whether to enable cluster autoscaler | `bool` | `true` | no |
| enable_metrics_server | Whether to enable metrics server | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the EKS cluster |
| cluster_arn | The ARN of the EKS cluster |
| cluster_endpoint | The endpoint for the Kubernetes API server |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| cluster_iam_role_arn | IAM role ARN of the EKS cluster |
| node_group_arn | ARN of the EKS node group |
| node_group_id | ID of the EKS node group |
| node_group_status | Status of the EKS node group |
| node_group_iam_role_arn | IAM role ARN of the EKS node group |
| kubeconfig | Kubernetes configuration for accessing the cluster |
