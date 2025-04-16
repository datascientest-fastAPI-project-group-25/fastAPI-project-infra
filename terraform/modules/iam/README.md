# IAM Module

This module creates IAM roles and policies for various AWS services and resources.

## Resources Created

1. **EKS IAM Role**
   - Role for EKS cluster
   - Policies for EKS cluster management
   - Trust relationship with EKS service

2. **EKS Node Group IAM Role**
   - Role for EKS worker nodes
   - Policies for EC2, ECR, and other required services
   - Trust relationship with EC2 service

3. **OIDC Provider**
   - OpenID Connect provider for GitHub Actions
   - Trust relationship with GitHub's OIDC provider

4. **GitHub Actions IAM Role**
   - Role for GitHub Actions workflows
   - Policies for AWS resource access
   - Trust relationship with GitHub OIDC provider

## Usage

```hcl
module "iam" {
  source = "../../modules/iam"

  project_name    = var.project_name
  environment     = var.environment
  github_org      = "datascientest-fastapi-project-group-25"
  repository_name = "fastapi-project-infra"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name (development, staging, production) | `string` | n/a | yes |
| github_org | GitHub organization or username | `string` | n/a | yes |
| repository_name | GitHub repository name | `string` | n/a | yes |
| eks_role_name | Name of the EKS IAM role | `string` | `""` | no |
| eks_node_role_name | Name of the EKS node group IAM role | `string` | `""` | no |
| github_actions_role_name | Name of the GitHub Actions IAM role | `string` | `""` | no |
| github_actions_role_policy_arns | List of policy ARNs to attach to the GitHub Actions role | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| eks_role_arn | ARN of the EKS IAM role |
| eks_node_role_arn | ARN of the EKS node group IAM role |
| github_actions_role_arn | ARN of the GitHub Actions IAM role |
| oidc_provider_arn | ARN of the OIDC provider |
