# GitHub Workflows for Infrastructure

This directory contains GitHub Actions workflows for automating infrastructure deployment and validation.

## Workflows

### 1. Terraform Validation (`terraform-validate.yml`)

This workflow runs on pull requests to the `development` and `main` branches. It performs:

- Terraform format check
- Terraform validation
- Security scanning with tfsec and checkov

### 2. Terraform Deployment (`terraform-deploy.yml`)

This workflow runs when changes are pushed to the `development` and `main` branches. It:

- Runs Terraform plan for the appropriate environments
- Uploads the plan as an artifact
- Applies the plan (with auto-approval for development/staging, manual approval for production)

Environment mapping:
- `development` branch → development and staging environments
- `main` branch → production environment

### 3. Pull Request Automation (`create-pr.yml`)

This workflow runs when changes are pushed to feature or fix branches. It:

- Creates a pull request to the `development` branch
- Adds appropriate labels for review

## Branching Strategy

```
main (production-ready)
  ↑
development (integration branch)
  ↑
feat/* or fix/* (feature/fix branches)
```

## Environment Strategy

Each environment has its own:
- EKS cluster
- VPC and networking resources
- Security groups
- Kubernetes namespaces

Production environment also uses RDS for the database instead of in-cluster PostgreSQL.

## Security Considerations

- Production deployments require manual approval
- Sensitive values are stored in GitHub Secrets
- Security scanning is performed on all infrastructure changes
- Least privilege principle is applied to IAM roles
