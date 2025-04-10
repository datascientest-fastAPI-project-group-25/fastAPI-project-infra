# FastAPI Project Infrastructure

This repository contains the Terraform code for deploying the FastAPI project infrastructure.

## Structure

The infrastructure is organized as follows:

```
terraform/
├── environments/           # Environment-specific configurations
│   ├── development/        # Development environment
│   ├── staging/            # Staging environment
│   └── production/         # Production environment
├── modules/                # Shared modules
│   ├── argo/               # ArgoCD configuration
│   ├── eks/                # EKS cluster
│   ├── k8s-resources/      # Kubernetes resources
│   ├── rds/                # RDS database (used in production)
│   ├── security/           # Security groups and IAM roles
│   └── vpc/                # VPC and networking
├── shared/                 # Shared configurations
│   ├── providers.tf        # Standard provider versions
│   └── variables.tf        # Common variable definitions
└── main.tf                 # Root configuration (for development)
```

## Deployment Model

Each environment (development, staging, production) is deployed independently with its own state file. This provides isolation and reduces the blast radius of changes.

### State Management

- Each environment has its own state file in S3
- State files are locked using DynamoDB to prevent concurrent modifications

### Provider Configuration

- Provider versions are standardized in `shared/providers.tf`
- Each environment has its own provider configuration because they're applied independently
- Kubernetes providers are configured after the EKS cluster is created

## Environment Differences

- **Development**: Uses in-cluster database, smaller instance types
- **Staging**: Uses in-cluster database, medium instance types
- **Production**: Uses RDS for the database, larger instance types, higher redundancy

## Deployment Process

To deploy an environment:

1. Navigate to the environment directory:
   ```
   cd terraform/environments/[environment]
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

## Best Practices

- Always use the same provider versions across environments
- Test changes in development before applying to staging or production
- Use separate state files for each environment
- Use consistent naming conventions across all resources
