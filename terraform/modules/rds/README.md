# RDS Module

This module creates an Amazon Relational Database Service (RDS) instance for PostgreSQL.

## Resources Created

1. **RDS Instance**
   - PostgreSQL database engine
   - Multi-AZ deployment (optional)
   - Automated backups
   - Encryption at rest

2. **Security Group**
   - Inbound rules for database access
   - Outbound rules for database connections

3. **Subnet Group**
   - Database subnet group for RDS instance placement

4. **Parameter Group**
   - Custom database parameters

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.database_subnets
  db_name         = "fastapi"
  db_username     = var.db_username
  db_password     = var.db_password
  instance_class  = "db.t3.small"
  multi_az        = var.environment == "production" ? true : false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name (development, staging, production) | `string` | n/a | yes |
| vpc_id | ID of the VPC where the RDS instance will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the RDS instance | `list(string)` | n/a | yes |
| db_name | Name of the database to create | `string` | n/a | yes |
| db_username | Username for the database | `string` | n/a | yes |
| db_password | Password for the database | `string` | n/a | yes |
| instance_class | Instance class for the RDS instance | `string` | `"db.t3.small"` | no |
| allocated_storage | Allocated storage in GB | `number` | `20` | no |
| max_allocated_storage | Maximum allocated storage in GB | `number` | `100` | no |
| storage_type | Storage type for the RDS instance | `string` | `"gp2"` | no |
| engine | Database engine | `string` | `"postgres"` | no |
| engine_version | Database engine version | `string` | `"14"` | no |
| multi_az | Whether to create a multi-AZ deployment | `bool` | `false` | no |
| backup_retention_period | Backup retention period in days | `number` | `7` | no |
| deletion_protection | Whether to enable deletion protection | `bool` | `false` | no |
| skip_final_snapshot | Whether to skip the final snapshot when deleting the instance | `bool` | `true` | no |
| apply_immediately | Whether to apply changes immediately | `bool` | `false` | no |
| security_group_ids | List of security group IDs to associate with the RDS instance | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | The ID of the RDS instance |
| db_instance_address | The address of the RDS instance |
| db_instance_endpoint | The connection endpoint of the RDS instance |
| db_instance_name | The database name |
| db_instance_username | The master username for the database |
| db_instance_port | The database port |
| db_subnet_group_id | The ID of the DB subnet group |
| db_security_group_id | The ID of the security group created for the RDS instance |
| db_parameter_group_id | The ID of the DB parameter group |
