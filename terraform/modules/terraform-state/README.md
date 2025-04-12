# Terraform State Module

This module sets up the necessary AWS resources for managing Terraform state with OIDC authentication for GitHub Actions.

## Resources Created

1. **S3 Bucket for Terraform State**
   - Versioning enabled
   - Server-side encryption
   - Public access blocked

2. **DynamoDB Table for State Locking**
   - Prevents concurrent state modifications
   - Pay-per-request billing mode

3. **OIDC Provider for GitHub Actions**
   - Enables secure authentication without long-lived credentials
   - Uses GitHub's OIDC token service

4. **IAM Role for Terraform State Access**
   - Assumed by GitHub Actions workflows
   - Limited to specific GitHub repositories
   - Permissions for S3 and DynamoDB access

## Usage

```hcl
module "terraform_state" {
  source = "../../modules/terraform-state"

  environment      = "dev"
  project_name     = "fastapi-project"
  aws_region       = "us-east-1"
  github_org       = "datascientest-fastAPI-project-group-25"
  state_bucket_name = "fastapi-project-terraform-state-${var.aws_account_id}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (development, staging, production) | `string` | n/a | yes |
| project_name | Name of the project | `string` | n/a | yes |
| aws_region | AWS region | `string` | n/a | yes |
| github_org | GitHub organization or username | `string` | n/a | yes |
| state_bucket_name | Name of the S3 bucket for Terraform state | `string` | n/a | yes |
| lock_table_name | Name of the DynamoDB table for state locking | `string` | `"terraform-state-lock"` | no |

## Outputs

| Name | Description |
|------|-------------|
| state_bucket_name | Name of the S3 bucket for Terraform state |
| state_bucket_arn | ARN of the S3 bucket for Terraform state |
| lock_table_name | Name of the DynamoDB table for state locking |
| lock_table_arn | ARN of the DynamoDB table for state locking |
| oidc_provider_arn | ARN of the GitHub OIDC provider |
| terraform_state_access_role_arn | ARN of the IAM role for GitHub Actions to access Terraform state |

## Security Considerations

- The S3 bucket has versioning enabled to protect against accidental state loss
- Server-side encryption is enabled for the S3 bucket
- Public access is blocked for the S3 bucket
- The IAM role has least-privilege permissions
- The trust relationship is limited to specific GitHub repositories
