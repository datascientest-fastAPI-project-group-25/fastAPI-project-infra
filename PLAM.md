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

1. **Set Up AWS Authentication**:

   **Option 1: Use OIDC Authentication (Recommended)**
   ```bash
   # Set the AWS account ID
   export AWS_ACCOUNT_ID=your_account_id
   export AWS_DEFAULT_REGION=us-east-1

   # Use the OIDC authentication script
   ./scripts/deployment/deploy-with-oidc.sh
   ```

   **Option 2: Use AWS CLI Configuration**
   ```bash
   # Configure AWS CLI with your credentials
   aws configure

   # Set the AWS account ID
   export AWS_ACCOUNT_ID=your_account_id
   export AWS_DEFAULT_REGION=us-east-1
   ```

   **Option 3: Use IAM Roles (for EC2 or EKS)**
   ```bash
   # If running on EC2 or EKS with IAM roles, just set the account ID
   export AWS_ACCOUNT_ID=your_account_id
   export AWS_DEFAULT_REGION=us-east-1
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

# Set AWS account ID and region
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCOUNT_ID=your_account_id

# Verify AWS authentication
aws sts get-caller-identity || {
    echo "AWS authentication failed. Please configure AWS credentials."
    exit 1
}

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

## Terraform State Security

The Terraform state contains sensitive information and should be properly secured. This deployment plan uses the following security measures for Terraform state:

1. **S3 Bucket with Encryption**: The Terraform state is stored in an S3 bucket with server-side encryption enabled.

2. **DynamoDB Table for State Locking**: A DynamoDB table is used for state locking to prevent concurrent modifications.

3. **IAM Policies**: The S3 bucket and DynamoDB table are protected with IAM policies that restrict access to authorized users only.

4. **Versioning**: S3 bucket versioning is enabled to maintain a history of state files and allow for recovery if needed.

5. **Access Logging**: S3 bucket access logging is enabled to track all access to the state files.

To further enhance security, consider implementing:

- **Cross-Region Replication**: For disaster recovery purposes.
- **Regular Backups**: Of the Terraform state files.
- **Monitoring and Alerting**: For unauthorized access attempts.

## Troubleshooting

### Common Issues

1. **AWS Authentication Error**:
   - Verify AWS authentication using `aws sts get-caller-identity`
   - Check IAM permissions for the user or role
   - For OIDC authentication, verify the trust relationship is correctly configured
   - For IAM roles, verify the instance profile is correctly attached

2. **Terraform State Error**:
   - Verify S3 bucket and DynamoDB table exist
   - Check permissions for S3 bucket and DynamoDB table

3. **EKS Cluster Creation Error**:
   - Check VPC and subnet configuration
   - Verify IAM permissions for EKS cluster creation
   - For "Invalid for_each argument" errors with the EKS module:
     - Use the `-target` approach to first apply only the resources that the `for_each` depends on
     - Example: `terraform apply -target=module.eks.module.eks.aws_iam_role.this[0]`
     - Then run a full apply: `terraform apply`

4. **ArgoCD Installation Error**:
   - Check Kubernetes configuration
   - Verify Helm chart version compatibility

5. **GitHub Authentication Error**:
   - Verify GitHub token has appropriate permissions
   - Check GitHub organization and repository names

6. **Terraform for_each Error**:
   - Error message: "The 'for_each' map includes keys derived from resource attributes that cannot be determined until apply"
   - This occurs when Terraform can't determine the keys for a `for_each` map during the planning phase
   - Solutions:
     - Use the `-target` approach to first apply only the resources that the `for_each` depends on
     - Define static keys in your map and place dynamic values only in the map values
     - Use conditional creation with `count` instead of `for_each` for simpler cases
     - Modify the module source code to use a different approach (if possible)

## Next Steps: GitHub Actions and OIDC Integration

### GitHub Actions Workflow Update

1. **Update AWS Credentials Action**:
   - Update the AWS credentials action from v2 to v4 to address the AWS SDK deprecation warning
   - Commit and push the changes to the repository

2. **Update GitHub Repository Secrets**:
   - Update the `AWS_ACCOUNT_ID` secret in the GitHub repository to use the new AWS account ID (221082192409)

### GitHub Actions OIDC Verification

1. **Run the OIDC Setup Script**:
   ```bash
   # Set your AWS account ID
   export AWS_ACCOUNT_ID=221082192409
   export AWS_DEFAULT_REGION=us-east-1

   # Run the setup script
   bash scripts/setup-github-oidc-roles.sh
   ```

   This script will:
   - Create the GitHub OIDC provider in your AWS account if it doesn't exist
   - Create IAM roles for each environment (development, staging, production)
   - Configure the trust relationship to allow GitHub Actions to assume these roles
   - Attach the necessary permissions to the roles

2. **Verify IAM Role Setup**:
   ```bash
   # Verify the roles exist
   aws iam get-role --role-name github-actions-development
   aws iam get-role --role-name github-actions-staging
   aws iam get-role --role-name github-actions-production

   # Verify the trust relationship
   aws iam get-role --role-name github-actions-development --query 'Role.AssumeRolePolicyDocument'
   ```

3. **Update Trust Policy for OIDC Authentication**:
   If you encounter the error "Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity", you need to update the trust policy for the IAM roles:

   ```bash
   # Set your AWS account ID
   export AWS_ACCOUNT_ID=221082192409
   export AWS_DEFAULT_REGION=us-east-1

   # Run the update trust policy script
   bash scripts/update-github-oidc-trust-policy.sh
   ```

   This script will update the trust policy for the IAM roles to allow GitHub Actions to assume them using OIDC authentication. The trust policy will include the following conditions:

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Principal": {
                   "Federated": "arn:aws:iam::221082192409:oidc-provider/token.actions.githubusercontent.com"
               },
               "Action": "sts:AssumeRoleWithWebIdentity",
               "Condition": {
                   "StringEquals": {
                       "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                       "token.actions.githubusercontent.com:sub": "repo:datascientest-fastAPI-project-group-25/fastAPI-project-infra:pull_request"
                   }
               }
           }
       ]
   }
   ```

   This trust policy allows GitHub Actions to assume the IAM roles when running workflows from pull requests.

   You can verify that the trust policy has been updated correctly:

   ```bash
   aws iam get-role --role-name github-actions-staging --query 'Role.AssumeRolePolicyDocument'
   ```

4. **Test GitHub Actions Workflow**:
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

## Current Deployment Issues (April 2025)

Based on the error logs from the GitHub Actions workflow and our investigation, we've identified the following issues that need to be fixed:

1. **Invalid for_each Argument** - The `for_each` block in the `ghcr-secret` module is using dynamic keys that depend on values only known after the apply phase. This causes Terraform to fail during the plan phase because it cannot determine the full set of keys.

2. **State Lock Issues** - The Terraform state is getting locked during GitHub Actions workflows, especially when they're cancelled, causing future deployments to fail. This is a symptom of the underlying `for_each` issue, as it forces the use of `-target` approach for deployments.

3. **Missing Argo Module Implementation** - The `argo` module is missing its `main.tf` file, which is likely why some of the deployments were failing. This file is needed to define the resources that the module should create.

4. **Undeclared Variables** - The warnings indicate that variables like `aws_account_id` and `environment` are being used but not declared in the Terraform configuration.

5. **Resource Targeting (-target) Warnings** - The `-target` option is used during planning, which is not recommended for routine use. This can lead to partial plans and misaligned configurations.

6. **Deprecated Arguments** - Some resources are using deprecated arguments, which may lead to compatibility issues in the future.

### Fix Plan for Current Issues

We've created a branch `fix/terraform-deployment-errors` from `main` and implemented the following fixes:

#### 1. Fix the for_each Issue in ghcr-secret Module

The error "The 'for_each' map includes keys derived from resource attributes that cannot be determined until apply" occurs because the `ghcr-secret` module is using dynamic values in `for_each`. We've fixed this by:

- [x] Modifying the `ghcr-secret` module to use static keys instead of dynamic ones
- [x] Creating a local variable with a static map of namespaces
- [x] Filtering the map based on the input namespaces list
- [x] Updating the outputs to match the new implementation

Files modified:
- [x] `terraform/modules/ghcr-secret/main.tf`
- [x] `terraform/modules/ghcr-secret/outputs.tf`

#### 2. Add Missing main.tf for Argo Module

We discovered that the `argo` module was missing its `main.tf` file, which is likely why some of the deployments were failing. We've fixed this by:

- [x] Creating a new `main.tf` file for the `argo` module
- [x] Implementing the ArgoCD installation and configuration
- [x] Ensuring it works with the existing `outputs.tf` and `variables.tf` files

Files added:
- [x] `terraform/modules/argo/main.tf`

#### 3. Improve State Lock Handling

To address the state lock issues, we've enhanced the deployment script with:

- [x] State backup functionality to create backups before any operations
- [x] Improved error handling and reporting for state locks
- [x] Better logging of lock information
- [x] Windows compatibility improvements for the backend config file path

Files modified:
- [x] `scripts/deployment/deploy-with-target.sh`

#### 4. Create State Update Script

We've created a new script for safely removing deleted resources from the state file:

- [x] The script creates backups before modifying the state
- [x] It removes specific resources that have been manually deleted from AWS
- [x] It includes safety checks and confirmation prompts
- [x] It works with both Windows and Unix environments

Files added:
- [x] `scripts/update-state.sh`

#### 5. Fix Resource Targeting Warnings

The `-target` option is used during planning, which is not recommended for routine use. This can lead to partial plans and misaligned configurations. This issue will be largely resolved once the `for_each` issue is fixed, but we should also:

- [ ] Refactor the configuration to avoid using the `-target` option except in exceptional cases
- [ ] Split resources into separate modules or stages that can be applied independently
- [ ] Update the deployment script to use a more robust approach for handling dependencies

#### 6. Fix Undeclared Variables

The warnings indicate that variables like `aws_account_id` and `environment` are being used but not declared in the Terraform configuration. We need to:

- [ ] Declare all variables in the root module or relevant configuration file
- [ ] Update the terraform.tfvars file if necessary to provide values for these variables
- [ ] Ensure all variables have proper descriptions and type constraints

#### 7. Fix Deprecated Arguments

Some resources are using deprecated arguments, which may lead to compatibility issues in the future. We need to:

- [ ] Identify all resources using deprecated arguments
- [ ] Replace deprecated arguments with their recommended alternatives
- [ ] Update documentation to reflect the changes

### Implementation Status

1. [x] **Fixed the for_each Issue in ghcr-secret Module**
   - Modified the module to use static keys
   - Updated outputs to match the new implementation

2. [x] **Added Missing main.tf for Argo Module**
   - Created the missing file with proper implementation

3. [x] **Improved State Lock Handling**
   - Enhanced the deployment script with state backup functionality
   - Improved error handling and reporting

4. [x] **Created State Update Script**
   - Added a new script for safely removing deleted resources from state

5. [ ] **Fix Resource Targeting Warnings**
   - Not yet implemented - will be resolved once the for_each issue is fixed

6. [ ] **Fix Undeclared Variables**
   - Not yet implemented

7. [ ] **Fix Deprecated Arguments**
   - Not yet implemented

### Next Steps

1. [ ] **Create a Pull Request**:
   - [ ] Push the changes to GitHub
   - [ ] Create a PR from `fix/terraform-deployment-errors` to `main`

2. [ ] **Test the Changes**:
   - [ ] Let the GitHub workflow run to verify the fixes
   - [ ] Monitor for any issues

3. [ ] **Implement Remaining Fixes**:
   - [ ] Fix Resource Targeting Warnings
   - [ ] Fix Undeclared Variables
   - [ ] Fix Deprecated Arguments

4. [ ] **Deploy to Production**:
   - [ ] Once all fixes are verified, deploy to production
   - [ ] Monitor the deployment for any issues

5. [ ] **Document the Changes**:
   - [ ] Update documentation with the fixes and solutions
   - [ ] Share knowledge with the team

## Conclusion

By following this deployment plan, you will be able to successfully deploy the FastAPI project infrastructure to a new AWS account. The plan addresses the hardcoded values in the codebase and provides a step-by-step guide for deploying the infrastructure.

Remember to update all hardcoded values with your new AWS account information before deploying. Use the provided scripts to automate the deployment process and verify the deployment after each phase.
