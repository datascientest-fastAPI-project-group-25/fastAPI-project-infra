#!/bin/bash

# Script to set up IAM roles for GitHub Actions OIDC authentication

# Check if AWS_ACCOUNT_ID is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: AWS_ACCOUNT_ID environment variable is not set."
    echo "Please set it before running this script:"
    echo "export AWS_ACCOUNT_ID=your_aws_account_id"
    exit 1
fi

# Check if AWS credentials are available (from environment or IAM role)
aws sts get-caller-identity &>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: AWS credentials are not available or are invalid."
    echo "Please configure AWS credentials using one of these methods:"
    echo "1. Set up AWS CLI with 'aws configure'"
    echo "2. Use IAM roles for EC2 instances or EKS clusters"
    echo "3. Use OIDC authentication for GitHub Actions"
    exit 1
fi

# GitHub repository name
GITHUB_REPO="datascientest-fastAPI-project-group-25/fastAPI-project-infra"

# AWS region
AWS_REGION=${AWS_DEFAULT_REGION:-"us-east-1"}

# Create OIDC provider if it doesn't exist
echo "Checking if GitHub OIDC provider exists..."
if ! aws iam list-open-id-connect-providers --no-cli-pager | grep -q "token.actions.githubusercontent.com"; then
    echo "Creating GitHub OIDC provider..."
    aws iam create-open-id-connect-provider \
        --url "https://token.actions.githubusercontent.com" \
        --client-id-list "sts.amazonaws.com" \
        --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to create GitHub OIDC provider."
        exit 1
    fi
    echo "GitHub OIDC provider created successfully."
else
    echo "GitHub OIDC provider already exists."
fi

# Function to create IAM role with trust relationship
create_github_actions_role() {
    local environment=$1
    local role_name="github-actions-${environment}"

    echo "Creating IAM role: ${role_name}..."

    # Create trust policy document
    cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPO}:*"
                }
            }
        }
    ]
}
EOF

    # Check if role exists
    if aws iam get-role --role-name "${role_name}" --no-cli-pager 2>/dev/null; then
        echo "Role ${role_name} already exists. Updating trust relationship..."
        aws iam update-assume-role-policy --role-name "${role_name}" --policy-document file://trust-policy.json --no-cli-pager
    else
        echo "Creating new role ${role_name}..."
        aws iam create-role --role-name "${role_name}" --assume-role-policy-document file://trust-policy.json --no-cli-pager
    fi

    # Attach AdministratorAccess policy (you may want to use a more restrictive policy in production)
    echo "Attaching AdministratorAccess policy to ${role_name}..."
    aws iam attach-role-policy --role-name "${role_name}" --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess" --no-cli-pager

    # Clean up
    rm trust-policy.json

    echo "IAM role ${role_name} created/updated successfully."
}

# Create roles for each environment
echo "Setting up IAM roles for GitHub Actions OIDC authentication..."
create_github_actions_role "development"
create_github_actions_role "staging"
create_github_actions_role "production"

echo "All IAM roles have been set up successfully."
echo "GitHub Actions should now be able to assume these roles using OIDC authentication."
