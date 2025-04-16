# VPC Module

This module creates a Virtual Private Cloud (VPC) in AWS with public and private subnets across multiple availability zones.

## Resources Created

1. **VPC**
   - CIDR block as specified in the variables
   - DNS support and hostnames enabled
   - Tags for Kubernetes cluster integration

2. **Subnets**
   - Public subnets for internet-facing resources
   - Private subnets for internal resources
   - Database subnets for RDS instances

3. **Internet Gateway**
   - For public subnet internet access

4. **NAT Gateway**
   - For private subnet outbound internet access

5. **Route Tables**
   - Public route tables with routes to the internet gateway
   - Private route tables with routes to the NAT gateway
   - Database route tables with routes to the NAT gateway

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  cidr         = var.cidr
  azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name (development, staging, production) | `string` | n/a | yes |
| cidr | CIDR block for the VPC | `string` | n/a | yes |
| azs | List of availability zones | `list(string)` | n/a | yes |
| public_subnets | List of public subnet CIDR blocks | `list(string)` | `[]` | no |
| private_subnets | List of private subnet CIDR blocks | `list(string)` | `[]` | no |
| database_subnets | List of database subnet CIDR blocks | `list(string)` | `[]` | no |
| enable_nat_gateway | Whether to enable NAT Gateway | `bool` | `true` | no |
| single_nat_gateway | Whether to use a single NAT Gateway | `bool` | `true` | no |
| enable_dns_hostnames | Whether to enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Whether to enable DNS support in the VPC | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| public_subnets | List of IDs of public subnets |
| private_subnets | List of IDs of private subnets |
| database_subnets | List of IDs of database subnets |
| public_route_table_ids | List of IDs of public route tables |
| private_route_table_ids | List of IDs of private route tables |
| database_route_table_ids | List of IDs of database route tables |
| nat_gateway_ids | List of NAT Gateway IDs |
| internet_gateway_id | ID of the Internet Gateway |
