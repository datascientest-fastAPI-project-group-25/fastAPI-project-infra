# Security Module

This module creates security groups for various resources in the AWS infrastructure.

## Resources Created

1. **EKS Security Group**
   - Inbound rules for Kubernetes API server
   - Outbound rules for worker nodes

2. **RDS Security Group**
   - Inbound rules for database access
   - Outbound rules for database connections

3. **Application Security Group**
   - Inbound rules for application access
   - Outbound rules for application connections

## Usage

```hcl
module "security" {
  source = "../../modules/security"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  eks_cluster_sg  = module.eks.cluster_security_group_id
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name (development, staging, production) | `string` | n/a | yes |
| vpc_id | ID of the VPC where the security groups will be created | `string` | n/a | yes |
| eks_cluster_sg | Security group ID of the EKS cluster | `string` | n/a | yes |
| db_port | Port for database access | `number` | `5432` | no |
| app_port | Port for application access | `number` | `8080` | no |
| cidr_blocks | List of CIDR blocks to allow access from | `list(string)` | `["0.0.0.0/0"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| eks_security_group_id | The ID of the EKS security group |
| rds_security_group_id | The ID of the RDS security group |
| app_security_group_id | The ID of the application security group |
