# FastAPI Project Infrastructure

Infrastructure as Code (IaC) repository for managing the FastAPI project infrastructure using Terraform.

## 📋 Project Overview

This repository contains the infrastructure code for the FastAPI project, organized into two main components:

| Component | Description |
|-----------|-------------|
| **Bootstrap** | Sets up foundational AWS resources (S3, DynamoDB, IAM) |
| **Terraform** | Manages the main application infrastructure |

## 🏗️ Architecture

![Infrastructure Architecture](https://mermaid.ink/img/pako:eNp1kMFqwzAMhl9F-NRCXyDQQw9bKYUNtl56ETLWEjOcyMhyxyB594nEhbXQnWT9_z99kjdUziFqVK_4cOQJPFqPgRJYCMxJBPZgKdCMNmAiS5FCYOcpwYTOUqDXYCjQO_qEgZxlP1MIFNlToBHHGSKNZMFjILvgGMgvOEZyC46JhoVjJrtwLDTNHAu5mWOlbuJYyU8cG7ULx0bNzLFTvXDs5CeOg-qF46Bm5jjITxwntTPHSe3CcZKfOC6qFo6L6pnjIj9x3FSNjpvKwXFTMThuciPjTfngeJPvHR_Kro6P8r3jU9nV8Sl_c3yW7Ryf8p3jS9nW8SXfOr7Kto6v8q3ju2zr-C7fOH7Kto6f8o3jV9nW8avs4vhd1jt-l_WO_2Wd43_Z2vG_rHP8K1s7_pV1jv9la8e_ss7xXbZ2fJf_AK6Jqzc?type=png)

## 📁 Directory Structure

| Directory | Description |
|-----------|-------------|
| `bootstrap/` | Infrastructure bootstrap code |
| `bootstrap/environments/` | Environment-specific configurations |
| `bootstrap/modules/` | Reusable Terraform modules |
| `bootstrap/scripts/` | Utility scripts for environment setup |

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI**: Installed and configured with appropriate credentials
2. **Terraform**: Version 1.0.0 or later
3. **Make**: For running automation commands
4. **Docker**: Required for running LocalStack and the dockerized environments

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/fastapi-project-infra.git
   cd fastapi-project-infra
   ```

2. **Set up environment variables**
   ```bash
   cp bootstrap/.env.base.example bootstrap/.env.base
   # Edit the file with your AWS credentials
   ```

### LocalStack Development

```bash
# Start LocalStack
make -C bootstrap start-localstack

# Initialize Terraform
make -C bootstrap local-init

# Plan and apply changes
make -C bootstrap local-plan
make -C bootstrap local-apply

# Run a bootstrap dry run (create, test, destroy resources)
make -C bootstrap localstack-bootstrap-dryrun

# Clean up when done
make -C bootstrap local-destroy
make -C bootstrap stop-localstack
```

### AWS Deployment

```bash
# Prepare AWS environment (package Lambda functions)
make -C bootstrap aws-prepare

# Set up Terraform state resources
make -C bootstrap aws-setup-state

# Initialize Terraform
make -C bootstrap aws-init

# Plan and apply changes
make -C bootstrap aws-plan
make -C bootstrap aws-apply

# Run a bootstrap dry run (create, test, destroy resources)
make -C bootstrap aws-bootstrap-dryrun
```

### Dockerized Environments

Both bootstrap environments (AWS and LocalStack) have been dockerized to ensure they can run on any system.

```bash
# Build Docker images
make -C bootstrap docker-build

# Start AWS environment in Docker
make -C bootstrap docker-aws

# Start LocalStack environment in Docker
make -C bootstrap docker-localstack

# Run bootstrap dry run in AWS using Docker
make -C bootstrap docker-aws-bootstrap-dryrun

# Run bootstrap dry run in LocalStack using Docker
make -C bootstrap docker-localstack-bootstrap-dryrun

# Test both environments
make -C bootstrap docker-test

# Clean up Docker resources
make -C bootstrap docker-clean
```

For more information, see the [Bootstrap README](bootstrap/README.md).

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

## 🔐 AWS Credentials

### Required Credentials

| Credential | Description | Secret Name |
|------------|-------------|------------|
| **AWS Account ID** | Your 12-digit AWS account number | `AWS_ACCOUNT_ID` |
| **Access Key ID** | AWS access key for authentication | `AWS_ACCESS_KEY_ID` |
| **Secret Access Key** | AWS secret key for authentication | `AWS_SECRET_ACCESS_KEY` |

### Setup Process

1. **Navigate to repository settings**
   - Go to your GitHub repository
   - Click "Settings" → "Secrets and variables" → "Actions"

2. **Add the required secrets**:
   ```
   AWS_ACCOUNT_ID         # Your 12-digit AWS account ID
   AWS_ACCESS_KEY_ID      # Your AWS access key
   AWS_SECRET_ACCESS_KEY  # Your AWS secret key
   ```

### Usage in Workflows

The GitHub Actions workflows automatically use these secrets:

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
  AWS_DEFAULT_REGION: eu-west-2
```

### Security Best Practices

| Practice | Description |
|----------|-------------|
| **Use Secrets** | Never commit credentials to the repository |
| **Limit Permissions** | Use IAM roles with minimal required access |
| **Rotate Keys** | Regularly change access keys |
| **Monitor Activity** | Watch for unusual AWS account activity |

## 🌍 Environment Variables

### Environment Structure

![Environment Variables Flow](https://mermaid.ink/img/pako:eNp1ksFqwzAMhl9F-NRCXyDQQw9bKYUNtl56ETLWEjOcyMhyxyB594nEhbXQnWT9_z99kjdUziFqVK_4cOQJPFqPgRJYCMxJBPZgKdCMNmAiS5FCYOcpwYTOUqDXYCjQO_qEgZxlP1MIFNlToBHHGSKNZMFjILvgGMgvOEZyC46JhoVjJrtwLDTNHAu5mWOlbuJYyU8cG7ULx0bNzLFTvXDs5CeOg-qF46Bm5jjITxwntTPHSe3CcZKfOC6qFo6L6pnjIj9x3FSNjpvKwXFTMThuciPjTfngeJPvHR_Kro6P8r3jU9nV8Sl_c3yW7Ryf8p3jS9nW8SXfOr7Kto6v8q3ju2zr-C7fOH7Kto6f8o3jV9nW8avs4vhd1jt-l_WO_2Wd43_Z2vG_rHP8K1s7_pV1jv9la8e_ss7xXbZ2fJf_AK6Jqzc?type=png)

### File Structure

| Location | File | Purpose |
|----------|------|---------|
| **Root** | `.env.base` | Common settings for all environments |
| **Root** | `.env.<environment>` | Environment-specific settings |
| **Bootstrap** | `bootstrap/.env.base` | Common bootstrap settings |
| **Bootstrap** | `bootstrap/.env.<environment>` | Bootstrap-specific settings |
| **Environments** | `bootstrap/environments/aws/.env.aws` | AWS-specific variables |
| **Environments** | `bootstrap/environments/localstack/.env.local` | LocalStack-specific variables |
| **Tests** | `tests/.env.test` | Test-specific variables |
| **Tests** | `tests/.env.local-test` | Local test variables for GitHub Actions |

### Loading Order

Variables are loaded in the following order, with later files overriding earlier ones:

1. `.env.base` → 2. `.env.<environment>` → 3. `bootstrap/.env.base` → 4. `bootstrap/.env.<environment>`

### Example Variables

```bash
# Common Variables (.env.base)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_ACCOUNT_ID=your-aws-account-id
PROJECT_NAME=fastapi-project

# Environment Variables (.env.<environment>)
AWS_DEFAULT_REGION=eu-west-2
ENVIRONMENT=dev

# AWS-Specific Variables
AWS_BOOTSTRAP_ROLE_NAME=terraform-bootstrap-role
AWS_BOOTSTRAP_POLICY_NAME=terraform-bootstrap-policy
```

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

### Environment Structure

Instead of using separate branches for different environments, we use folder-based environments:

- `environments/stg/`: Configuration for the staging environment.
- `environments/prod/`: Configuration for the production environment.

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
