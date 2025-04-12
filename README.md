# FastAPI Project Infrastructure

Infrastructure as Code (IaC) repository for managing the FastAPI project infrastructure using Terraform with OIDC authentication for secure GitHub Actions integration.

## 📋 Project Overview

This repository contains the infrastructure code for the FastAPI project, organized into three main components:

| Component | Description |
|-----------|-------------|
| **Bootstrap** | Sets up foundational AWS resources (S3, DynamoDB, IAM) |
| **Terraform Modules** | Reusable infrastructure components (VPC, EKS, ArgoCD, etc.) |
| **Environment Deployments** | Environment-specific configurations (Development, Staging, Production) |

## 🏗️ Architecture

![Infrastructure Architecture](https://mermaid.ink/img/pako:eNp1kMFqwzAMhl9F-NRCXyDQQw9bKYUNtl56ETLWEjOcyMhyxyB594nEhbXQnWT9_z99kjdUziFqVK_4cOQJPFqPgRJYCMxJBPZgKdCMNmAiS5FCYOcpwYTOUqDXYCjQO_qEgZxlP1MIFNlToBHHGSKNZMFjILvgGMgvOEZyC46JhoVjJrtwLDTNHAu5mWOlbuJYyU8cG7ULx0bNzLFTvXDs5CeOg-qF46Bm5jjITxwntTPHSe3CcZKfOC6qFo6L6pnjIj9x3FSNjpvKwXFTMThuciPjTfngeJPvHR_Kro6P8r3jU9nV8Sl_c3yW7Ryf8p3jS9nW8SXfOr7Kto6v8q3ju2zr-C7fOH7Kto6f8o3jV9nW8avs4vhd1jt-l_WO_2Wd43_Z2vG_rHP8K1s7_pV1jv9la8e_ss7xXbZ2fJf_AK6Jqzc?type=png)

## 📁 Directory Structure

| Directory | Description |
|-----------|-------------|
| `bootstrap/` | Infrastructure bootstrap code |
| `bootstrap/environments/` | Environment-specific bootstrap configurations |
| `bootstrap/modules/` | Reusable bootstrap Terraform modules |
| `bootstrap/scripts/` | Utility scripts for bootstrap setup |
| `terraform/modules/` | Reusable infrastructure modules |
| `terraform/modules/argo/` | ArgoCD deployment module |
| `terraform/modules/eks/` | EKS cluster module |
| `terraform/modules/external-secrets/` | External Secrets Operator module |
| `terraform/modules/ghcr-access/` | GitHub Container Registry access module |
| `terraform/modules/iam/` | IAM roles and policies module |
| `terraform/modules/k8s-resources/` | Kubernetes resources module |
| `terraform/modules/oidc/` | OIDC provider module |
| `terraform/modules/rds/` | RDS database module |
| `terraform/modules/security/` | Security groups module |
| `terraform/modules/vpc/` | VPC network module |
| `terraform/environments/` | Environment-specific deployments |
| `terraform/environments/clean-deploy/` | Clean deployment approach |
| `terraform/environments/clean-deploy/development/` | Development environment configuration |
| `terraform/environments/clean-deploy/staging/` | Staging environment configuration |
| `terraform/environments/clean-deploy/production/` | Production environment configuration |

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI**: Installed and configured with appropriate credentials
2. **Terraform**: Version 1.5.7 or later
3. **kubectl**: For interacting with Kubernetes clusters
4. **GitHub Account**: For OIDC authentication

### Environment Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-infra.git
   cd fastAPI-project-infra
   ```

2. **Set up AWS credentials**

   ```bash
   aws configure
   # Enter your AWS Access Key ID, Secret Access Key, and default region
   ```

### Setting up Terraform State

```bash
# Create S3 bucket and DynamoDB table for Terraform state
./setup-state.sh
```

### Deploying with OIDC Authentication

```bash
# Deploy infrastructure with OIDC authentication
./deploy-with-oidc.sh
```

### Staged Deployment

For more control, you can deploy each component separately:

```bash
# Deploy IAM resources
cd terraform/environments/clean-deploy/development
terraform init \
  -backend-config="bucket=fastapi-project-terraform-state-YOUR_AWS_ACCOUNT_ID" \
  -backend-config="key=fastapi/infra/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-state-lock-dev"
terraform apply -target=module.iam

# Deploy VPC
terraform apply -target=module.vpc

# Deploy security groups
terraform apply -target=module.security

# Deploy EKS cluster
terraform apply -target=module.eks

# Deploy Kubernetes resources
terraform apply -target=module.k8s_resources

# Deploy ArgoCD
terraform apply -target=module.argocd

# Deploy External Secrets Operator
terraform apply -target=module.external_secrets

# Deploy GHCR access
terraform apply -target=module.ghcr_access
```

For more information, see the [Clean Deploy README](terraform/environments/clean-deploy/README.md).

## 🛠️ Make Commands

### Root Makefile Commands

| Command | Description |
|---------|-------------|
| `make ENV=aws tf_plan` | Run Terraform plan for AWS environment |
| `make tf_plan` | Run Terraform plan for LocalStack environment (default) |
| `make ENV=test test` | Run tests using test environment |
| `make ENV=local-test act_mock` | Run GitHub Actions locally with Act |
| `make git_feature` | Create a new feature branch |
| `make git_fix` | Create a new fix branch |
| `make git_commit` | Commit changes in logical groups |
| `make git_push` | Push current branch to remote |
| `make git_merge_main` | Merge current branch to main branch |
| `make git_status` | Show git status |
| `make help` | Show all available commands |

### Bootstrap Makefile Commands

| Command | Description |
|---------|-------------|
| `make -C bootstrap start-localstack` | Start LocalStack container |
| `make -C bootstrap local-init` | Initialize Terraform for LocalStack |
| `make -C bootstrap local-apply` | Apply changes to LocalStack |
| `make -C bootstrap aws-prepare` | Package Lambda for AWS deployment |
| `make -C bootstrap aws-bootstrap-dryrun` | Run AWS bootstrap dry run |
| `make -C bootstrap help` | Show all bootstrap commands |

### Docker-based Bootstrap Commands

| Command | Description |
|---------|-------------|
| `make -C bootstrap docker-build` | Build Docker images for AWS and LocalStack |
| `make -C bootstrap docker-aws` | Start AWS environment in Docker |
| `make -C bootstrap docker-localstack` | Start LocalStack environment in Docker |
| `make -C bootstrap docker-aws-setup-state` | Set up Terraform state in AWS using Docker |
| `make -C bootstrap docker-aws-bootstrap-dryrun` | Run AWS bootstrap dry run in Docker |
| `make -C bootstrap docker-localstack-bootstrap-dryrun` | Run LocalStack bootstrap dry run in Docker |
| `make -C bootstrap docker-test` | Test both Docker environments |
| `make -C bootstrap docker-clean` | Clean up Docker resources |

## 🔐 AWS Authentication

### OIDC Authentication

This project uses OpenID Connect (OIDC) for secure authentication between GitHub Actions and AWS, eliminating the need for long-lived AWS credentials.

#### Benefits of OIDC

| Benefit | Description |
|---------|-------------|
| **No Stored Secrets** | No AWS credentials stored in GitHub Secrets |
| **Short-lived Credentials** | Temporary credentials generated on-demand |
| **Fine-grained Permissions** | Precise control over which repositories and branches can access AWS resources |
| **Reduced Risk** | Eliminates risk of leaked credentials |

### Required Configuration

| Resource | Description |
|----------|-------------|
| **OIDC Provider** | AWS IAM OIDC provider for GitHub Actions |
| **IAM Role** | Role with appropriate permissions that GitHub Actions can assume |
| **Trust Relationship** | Policy that allows specific GitHub repositories to assume the role |

### Setup Process

1. **Create OIDC Provider**
   - This is automatically created by the `setup-state.sh` script
   - Or manually create an OIDC provider with URL `https://token.actions.githubusercontent.com`

2. **Create IAM Role**
   - This is automatically created by the `setup-state.sh` script
   - Or manually create a role with appropriate permissions and trust relationship

### Usage in Workflows

The GitHub Actions workflows automatically use OIDC authentication:

```yaml
permissions:
  id-token: write  # Required for OIDC authentication
  contents: read

jobs:
  deploy:
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
          aws-region: us-east-1
```

### Security Best Practices

| Practice | Description |
|----------|-------------|
| **Restrict by Repository** | Limit which repositories can assume the role |
| **Restrict by Branch** | Limit which branches can assume the role |
| **Least Privilege** | Grant only the permissions needed for the workflow |
| **Monitor Activity** | Watch for unusual AWS account activity |
| **Regular Audits** | Periodically review OIDC configurations and permissions |

## 🌍 Environment Configuration

### Environment Structure

The infrastructure is organized into three environments, each with its own configuration:

| Environment | Purpose | Characteristics |
|-------------|---------|----------------|
| **Development** | For development and testing | Lightweight, in-cluster PostgreSQL |
| **Staging** | Pre-production testing | Mirrors production with smaller resources, RDS PostgreSQL |
| **Production** | Live environment | High availability, RDS PostgreSQL with multi-AZ |

### Configuration Files

| Location | Purpose |
|----------|--------|
| `terraform/environments/clean-deploy/development/` | Development environment configuration |
| `terraform/environments/clean-deploy/staging/` | Staging environment configuration |
| `terraform/environments/clean-deploy/production/` | Production environment configuration |
| `terraform/environments/clean-deploy/development/terraform.tfvars` | Development-specific variables |
| `terraform/environments/clean-deploy/staging/terraform.tfvars` | Staging-specific variables |
| `terraform/environments/clean-deploy/production/terraform.tfvars` | Production-specific variables |

### Terraform Variables

Each environment has its own set of variables defined in `terraform.tfvars` files:

```hcl
# Example Development Variables (development/terraform.tfvars)
project_name    = "fastapi-project"
environment     = "dev"
aws_region      = "us-east-1"
cidr            = "10.0.0.0/16"
db_username     = "postgres"
db_password     = "postgres123"
github_token    = "ghp_xxxxxxxxxxxxxxxxxxxx"

# Cluster Configuration
eks_cluster_name = "fastapi-project-eks-dev"
eks_cluster_version = "1.27"
eks_instance_types = ["t3.small"]
```

### Environment-Specific Differences

| Feature | Development | Staging | Production |
|---------|------------|---------|------------|
| **Database** | In-cluster PostgreSQL | RDS PostgreSQL | RDS PostgreSQL (Multi-AZ) |
| **Instance Types** | t3.small | t3.medium | t3.large |
| **Node Count** | 2 | 2 | 3 |
| **CIDR Range** | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| **Self-healing** | Basic | Enhanced | Full |
| **Monitoring** | Basic | Enhanced | Comprehensive |

## 🔄 Development Workflow

1. **Bootstrap** infrastructure provides foundational resources
2. **Deploy** main infrastructure using bootstrapped resources
3. **Test** changes locally using LocalStack
4. **Contribute** by creating pull requests

## 🌿 Git Workflow

This project follows a trunk-based development model to maintain code quality and facilitate collaboration.

### Branch Structure

- `main`: Production branch (protected)
- `feat/*`: Feature branches
- `fix/*`: Bug fix branches

### Folder-Based Environments

Instead of using separate branches for different environments, we use folder-based environments:

- `terraform/environments/clean-deploy/development/`: Configuration for the development environment.
- `terraform/environments/clean-deploy/staging/`: Configuration for the staging environment.
- `terraform/environments/clean-deploy/production/`: Configuration for the production environment.

### Git Commands

| Command | Description |
|---------|-------------|
| `make git_feature` | Create a new feature branch |
| `make git_fix` | Create a new fix branch |
| `make git_commit` | Commit changes in logical groups |
| `make git_push` | Push current branch to remote |
| `make git_merge_main` | Merge current branch to main branch |
| `make git_status` | Show git status |

For detailed information about the Git workflow, see [BRANCHING.md](BRANCHING.md).

An example script demonstrating the Git workflow is available in [examples/git-workflow-example.sh](examples/git-workflow-example.sh).

## 📄 License

See [LICENSE](LICENSE) file.
