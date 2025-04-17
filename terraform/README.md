# Terraform Configuration

This directory contains the Terraform configuration for the FastAPI project infrastructure.

## Directory Structure

- **environments/**: Contains environment-specific Terraform configurations
  - **clean-deploy/**: Contains the clean deployment approach configurations
    - **development/**: Development environment configuration
    - **staging/**: Staging environment configuration (to be implemented)
    - **production/**: Production environment configuration (to be implemented)
  - **argocd-deploy-clean/**: Contains ArgoCD-specific deployment configuration
- **modules/**: Contains reusable Terraform modules
  - **argo/**: ArgoCD deployment module
  - **eks/**: EKS cluster module
  - **external-secrets/**: External Secrets Operator module
  - **ghcr-access/**: GitHub Container Registry access module
  - **iam/**: IAM roles and policies module
  - **k8s-resources/**: Kubernetes resources module
  - **oidc/**: OIDC authentication module
  - **security/**: Security groups module
  - **vpc/**: VPC module
- **legacy/**: Contains the original Terraform configuration (kept for reference)

## Deployment

Use the scripts in the scripts/deployment directory to deploy the infrastructure.
The main deployment script is scripts/deployment/deploy-with-oidc.sh, which uses OIDC authentication.
