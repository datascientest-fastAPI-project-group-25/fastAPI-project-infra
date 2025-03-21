# FastAPI Project Infrastructure

This repository contains the infrastructure as code (IaC) for the FastAPI project using Terraform to provision AWS resources. It includes a GitHub Actions workflow for automated deployment using OpenID Connect (OIDC) for secure authentication with AWS.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Checkov](https://github.com/bridgecrewio/checkov) for security scanning

## Local Development

### Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-infra.git
   cd fastAPI-project-infra
   ```

2. Create a `.env` file based on the `.env.example` template:
   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file with your AWS credentials:
   ```
   AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
   AWS_REGION=eu-west-2
   ```

### Running Terraform Locally

Use the Makefile to run Terraform commands:

```bash
make terraform
```

Or run Terraform commands directly:

```bash
terraform init
terraform plan
terraform apply
```

## GitHub Actions CI/CD Pipeline

The repository includes a GitHub Actions workflow that automatically deploys the infrastructure when changes are pushed to the main branch.

### Setup for GitHub Actions

1. In your GitHub repository, go to Settings > Secrets and add the following secret:
   - `AWS_ACCOUNT_ID`: Your AWS account ID

2. Ensure the AWS OIDC provider is set up in your AWS account (this is automated in the Terraform configuration)

3. The GitHub Actions workflow will use OIDC to authenticate with AWS, assuming the `GitHubActionsRole` role

## Infrastructure Components

- **VPC**: A basic VPC setup with a subnet and internet gateway
- **S3 Bucket**: For storing Terraform state
- **DynamoDB Table**: For Terraform state locking
- **IAM Roles**: For GitHub Actions to access AWS resources securely using OIDC

## Security

- Checkov is used to scan the Terraform code for security issues
- OIDC is used for secure authentication between GitHub Actions and AWS
- S3 bucket for Terraform state has encryption enabled

## Contributing

1. Create a feature branch from main
2. Make your changes
3. Submit a pull request to main
4. After approval and merge, GitHub Actions will automatically deploy the changes