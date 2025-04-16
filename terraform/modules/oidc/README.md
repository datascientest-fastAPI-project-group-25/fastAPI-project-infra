# OIDC Module

This module creates an OpenID Connect (OIDC) provider for GitHub Actions and associated IAM roles.

## Resources Created

1. **OIDC Provider**
   - OpenID Connect provider for GitHub Actions
   - Trust relationship with GitHub's OIDC provider

2. **IAM Role**
   - Role for GitHub Actions workflows
   - Policies for AWS resource access
   - Trust relationship with GitHub OIDC provider

## Usage

```hcl
module "oidc" {
  source = "../../modules/oidc"

  github_org      = "datascientest-fastapi-project-group-25"
  repository_name = "fastapi-project-infra"
  role_name       = "github-actions-role"
  policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| github_org | GitHub organization or username | `string` | n/a | yes |
| repository_name | GitHub repository name | `string` | n/a | yes |
| role_name | Name of the IAM role for GitHub Actions | `string` | n/a | yes |
| policy_arns | List of policy ARNs to attach to the role | `list(string)` | n/a | yes |
| provider_url | URL of the OIDC provider | `string` | `"token.actions.githubusercontent.com"` | no |
| audience | Audience for the OIDC provider | `string` | `"sts.amazonaws.com"` | no |
| thumbprint_list | List of thumbprints for the OIDC provider | `list(string)` | `[]` | no |
| max_session_duration | Maximum session duration in seconds | `number` | `3600` | no |

## Outputs

| Name | Description |
|------|-------------|
| oidc_provider_arn | ARN of the OIDC provider |
| role_arn | ARN of the IAM role |
| role_name | Name of the IAM role |
