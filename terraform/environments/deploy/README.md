# FastAPI Project Infrastructure

This directory contains the Terraform configurations for deploying the FastAPI project infrastructure across multiple environments.

## Environment Structure

The infrastructure is organized into three environments:

1. **Development**: A lightweight environment for development and testing
   - Uses in-cluster PostgreSQL database
   - Smaller instance types (t3.small)
   - Minimal resource allocation

2. **Staging**: A pre-production environment that mirrors production
   - Uses RDS PostgreSQL database
   - Medium instance types (t3.medium)
   - Moderate resource allocation
   - Identical configuration to production but with smaller resources

3. **Production**: The live environment
   - Uses RDS PostgreSQL database with high availability (multi-AZ)
   - Larger instance types (t3.large)
   - Higher resource allocation
   - Self-healing enabled

## ArgoCD Deployment

Each environment has its own ArgoCD instance following the "Dedicated instance model":

- Each environment has its own EKS cluster
- ArgoCD is deployed within each cluster
- Each ArgoCD instance manages deployments for its specific environment
- No cross-environment management

## Deployment Instructions

### Development Environment

```bash
cd development
terraform init
terraform apply
```

### Staging Environment

```bash
cd staging
terraform init
terraform apply
```

### Production Environment

```bash
cd production
terraform init
terraform apply
```

## Staged Deployment

To handle dependencies and avoid circular references, the infrastructure can be deployed in stages using the Makefile:

### Development Staged Deployment

```bash
# Initialize the Terraform configuration
make init-dev

# Deploy each stage in sequence
make apply-dev-vpc
make apply-dev-security
make apply-dev-eks
make apply-dev-k8s
make apply-dev-argocd
make apply-dev-external-secrets
make apply-dev-ghcr
```

### Staging Staged Deployment

```bash
# Initialize the Terraform configuration
make init-staging

# Deploy each stage in sequence
make apply-staging-vpc
make apply-staging-security
make apply-staging-eks
make apply-staging-k8s
make apply-staging-argocd
make apply-staging-external-secrets
make apply-staging-ghcr
```

### Production Staged Deployment

```bash
# Initialize the Terraform configuration
make init-prod

# Deploy each stage in sequence
make apply-prod-vpc
make apply-prod-security
make apply-prod-eks
make apply-prod-k8s
make apply-prod-argocd
make apply-prod-external-secrets
make apply-prod-ghcr
```

## Important Notes

- Each environment uses a different VPC CIDR range to avoid conflicts
- Staging mirrors production configuration but with smaller resources
- Production uses multi-AZ RDS for high availability
- All environments use the same Kubernetes version for consistency

## Helper Scripts

Several helper scripts are provided to simplify the deployment process:

### update-secrets.sh

Updates sensitive variables in all environments:

```bash
./update-secrets.sh <github_token> <db_username> <db_password>
```

### deploy-all.sh

Deploys all environments in sequence (development, staging, production):

```bash
./deploy-all.sh <github_token> <db_username> <db_password>
```

### destroy-all.sh

Destroys all environments in reverse sequence (production, staging, development):

```bash
./destroy-all.sh
```

## Makefile

A Makefile is provided to simplify common operations:

```bash
# Initialize development environment
make init-dev

# Plan changes for development environment
make plan-dev

# Apply changes to development environment
make apply-dev

# Destroy development environment
make destroy-dev
```

Similar commands are available for staging and production environments.

## Check Scripts

Several check scripts are provided to verify the infrastructure:

### check-aws-permissions.sh

Checks AWS credentials and permissions:

```bash
./check-aws-permissions.sh
```

### check-kubernetes.sh

Checks Kubernetes configuration:

```bash
./check-kubernetes.sh
```

### check-argocd.sh

Checks ArgoCD installation in a specific environment:

```bash
./check-argocd.sh <environment>
```

Where `<environment>` can be: development, staging, production.

## ArgoCD Scripts

Scripts to interact with ArgoCD:

### get-argocd-password.sh

Gets the ArgoCD admin password for a specific environment:

```bash
./get-argocd-password.sh <environment>
```

### port-forward-argocd.sh

Port-forwards the ArgoCD UI for a specific environment:

```bash
./port-forward-argocd.sh <environment>
```

The ArgoCD UI will be available at: `https://localhost:8080`

Use 'admin' as the username and the password from get-argocd-password.sh.
