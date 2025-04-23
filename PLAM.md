# FastAPI Project Infrastructure Deployment Plan

## Overview

This document outlines the plan for deploying the FastAPI project infrastructure to a new AWS account. The current codebase contains hardcoded values that need to be updated to work with the new AWS account.

## Current Issues

1. **Hardcoded AWS Account IDs**: Several files contain hardcoded AWS account IDs that need to be updated.
2. **Hardcoded Credentials**: Some scripts and configuration files contain hardcoded AWS credentials.
3. **Hardcoded Region**: AWS region is hardcoded in multiple places.
4. **Hardcoded Resource Names**: S3 bucket names, DynamoDB table names, and other resource names are hardcoded.
5. **GitHub Tokens**: GitHub tokens are hardcoded in terraform.tfvars files.

## Deployment Plan

### Phase 1: Preparation and Configuration Update

1. **Update AWS Account Information**:
   - Update AWS account ID in all terraform.tfvars files
   - Update AWS region if needed
   - Create a centralized configuration file for AWS settings

2. **Update Terraform State Configuration**:
   - Create new S3 bucket for Terraform state in the new AWS account
   - Create new DynamoDB table for state locking
   - Update backend configuration in all Terraform modules

3. **Update GitHub Configuration**:
   - Generate new GitHub token with appropriate permissions
   - Update GitHub token in terraform.tfvars files
   - Update GitHub organization and repository names if needed

4. **Update Database Credentials**:
   - Generate new secure database credentials
   - Update database credentials in terraform.tfvars files

### Phase 2: Bootstrap the New AWS Account

1. **Set Up AWS Credentials**:
   ```bash
   # Create .env file with AWS credentials
   cat > .env << EOF
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   AWS_DEFAULT_REGION=us-east-1
   AWS_ACCOUNT_ID=your_account_id
   EOF
   ```

2. **Run AWS Connection Script**:
   ```bash
   # Run the AWS connection script to update all necessary files
   bash scripts/aws-connect.sh
   ```

3. **Create Terraform State Resources**:
   ```bash
   # Create S3 bucket and DynamoDB table for Terraform state
   bash scripts/setup-state.sh
   ```

4. **Bootstrap AWS Environment**:
   ```bash
   # Bootstrap the AWS environment with foundational resources
   cd bootstrap
   make aws-bootstrap-dryrun
   make aws-apply
   cd ..
   ```

### Phase 3: Deploy Infrastructure

1. **Deploy Development Environment**:
   ```bash
   # Initialize and deploy development environment
   cd terraform/environments/clean-deploy/development
   terraform init \
     -backend-config="bucket=fastapi-project-terraform-state-YOUR_AWS_ACCOUNT_ID" \
     -backend-config="key=fastapi/infra/development/terraform.tfstate" \
     -backend-config="region=us-east-1" \
     -backend-config="dynamodb_table=terraform-state-lock-dev"
   terraform apply -var-file=terraform.tfvars
   cd ../../../../
   ```

2. **Deploy Staging Environment** (if needed):
   ```bash
   # Initialize and deploy staging environment
   cd terraform/environments/clean-deploy/staging
   terraform init \
     -backend-config="bucket=fastapi-project-terraform-state-YOUR_AWS_ACCOUNT_ID" \
     -backend-config="key=fastapi/infra/staging/terraform.tfstate" \
     -backend-config="region=us-east-1" \
     -backend-config="dynamodb_table=terraform-state-lock-staging"
   terraform apply -var-file=terraform.tfvars
   cd ../../../../
   ```

3. **Deploy Production Environment** (if needed):
   ```bash
   # Initialize and deploy production environment
   cd terraform/environments/clean-deploy/production
   terraform init \
     -backend-config="bucket=fastapi-project-terraform-state-YOUR_AWS_ACCOUNT_ID" \
     -backend-config="key=fastapi/infra/production/terraform.tfstate" \
     -backend-config="region=us-east-1" \
     -backend-config="dynamodb_table=terraform-state-lock-production"
   terraform apply -var-file=terraform.tfvars
   cd ../../../../
   ```

### Phase 4: Verify Deployment

1. **Verify AWS Resources**:
   ```bash
   # Check AWS resources
   bash terraform/environments/clean-deploy/check-aws-permissions.sh
   ```

2. **Verify Kubernetes Configuration**:
   ```bash
   # Check Kubernetes configuration
   bash terraform/environments/clean-deploy/check-kubernetes.sh
   ```

3. **Verify ArgoCD Installation**:
   ```bash
   # Check ArgoCD installation
   bash terraform/environments/clean-deploy/check-argocd.sh development
   ```

4. **Access ArgoCD UI**:
   ```bash
   # Get ArgoCD password
   bash terraform/environments/clean-deploy/get-argocd-password.sh development

   # Port-forward ArgoCD UI
   bash terraform/environments/clean-deploy/port-forward-argocd.sh development
   ```

## Automated Deployment

For a fully automated deployment, use the following script:

```bash
#!/bin/bash

# Set AWS credentials
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=your_account_id

# Update AWS account information
sed -i "s/aws_account_id = .*/aws_account_id = \"$AWS_ACCOUNT_ID\"/" terraform/environments/clean-deploy/development/terraform.tfvars
sed -i "s/aws_account_id = .*/aws_account_id = \"$AWS_ACCOUNT_ID\"/" terraform/environments/clean-deploy/staging/terraform.tfvars
sed -i "s/aws_account_id = .*/aws_account_id = \"$AWS_ACCOUNT_ID\"/" terraform/environments/clean-deploy/production/terraform.tfvars

# Create Terraform state resources
bash scripts/setup-state.sh

# Bootstrap AWS environment
cd bootstrap
make aws-bootstrap-dryrun
make aws-apply
cd ..

# Deploy development environment
cd terraform/environments/clean-deploy
./deploy-all.sh your_github_token your_db_username your_db_password
cd ../../../
```

## Troubleshooting

### Common Issues

1. **AWS Credentials Error**:
   - Verify AWS credentials are correctly set in .env file
   - Check AWS permissions for the user

2. **Terraform State Error**:
   - Verify S3 bucket and DynamoDB table exist
   - Check permissions for S3 bucket and DynamoDB table

3. **EKS Cluster Creation Error**:
   - Check VPC and subnet configuration
   - Verify IAM permissions for EKS cluster creation

4. **ArgoCD Installation Error**:
   - Check Kubernetes configuration
   - Verify Helm chart version compatibility

5. **GitHub Authentication Error**:
   - Verify GitHub token has appropriate permissions
   - Check GitHub organization and repository names

## Next Steps: GitHub Actions and OIDC Integration

### GitHub Actions Workflow Update

1. **Update AWS Credentials Action**:
   - Update the AWS credentials action from v2 to v4 to address the AWS SDK deprecation warning
   - Commit and push the changes to the repository

2. **Update GitHub Repository Secrets**:
   - Update the `AWS_ACCOUNT_ID` secret in the GitHub repository to use the new AWS account ID (221082192409)

### GitHub Actions OIDC Verification

1. **Verify IAM Role Setup**:
   - Ensure the IAM role `github-actions-dev` exists in the new AWS account
   - Verify the trust relationship is correctly configured for GitHub Actions OIDC

2. **Test GitHub Actions Workflow**:
   - Trigger a workflow run to verify that the GitHub Actions can successfully authenticate with AWS
   - Monitor for any issues with the OIDC authentication

### ArgoCD Setup Completion

1. **Fix ArgoCD Application Sync Issue**:
   - ✅ GHCR secret has been updated with a valid GitHub token
   - ❌ Inform the release team about the Helm chart issue: The secrets.yaml template is trying to use `.Values.secrets.databaseUrl` and `.Values.secrets.secretKey`, but these values are defined under `.Values.configMap` in the values.yaml file
   - Verify that ArgoCD can successfully deploy applications from the release repository after the fix

2. **Resolve Image Pull Issues**:
   - ✅ GHCR secret is correctly configured with a valid GitHub token
   - ❌ Container images do not exist in the GitHub Container Registry. The error message is: `failed to resolve reference "ghcr.io/datascientest-fastapi-project-group-25/fastapi-project-app/backend:latest": ghcr.io/datascientest-fastapi-project-group-25/fastapi-project-app/backend:latest: not found`
   - Inform the application team to build and push the container images to the GitHub Container Registry

## Conclusion

By following this deployment plan, you will be able to successfully deploy the FastAPI project infrastructure to a new AWS account. The plan addresses the hardcoded values in the codebase and provides a step-by-step guide for deploying the infrastructure.

Remember to update all hardcoded values with your new AWS account information before deploying. Use the provided scripts to automate the deployment process and verify the deployment after each phase.
