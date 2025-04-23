#!/bin/bash

# Script to update the trust policy for GitHub Actions OIDC authentication

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

# Function to update IAM role trust policy
update_github_actions_role_trust_policy() {
    local environment=$1
    local role_name="github-actions-${environment}"

    echo "Updating trust policy for IAM role: ${role_name}..."

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
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPO}:pull_request"
                }
            }
        },
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
                    "token.actions.githubusercontent.com:sub": [
                        "repo:${GITHUB_REPO}:ref:refs/heads/main",
                        "repo:${GITHUB_REPO}:ref:refs/heads/feat/*",
                        "repo:${GITHUB_REPO}:ref:refs/pull/*"
                    ]
                }
            }
        }
    ]
}
EOF

    # Update trust policy
    aws iam update-assume-role-policy --role-name "${role_name}" --policy-document file://trust-policy.json --no-cli-pager

    # Clean up
    rm trust-policy.json

    echo "Trust policy for IAM role ${role_name} updated successfully."
}

# Update trust policy for each environment
echo "Updating trust policy for GitHub Actions OIDC authentication..."
update_github_actions_role_trust_policy "staging"
update_github_actions_role_trust_policy "production"

echo "All trust policies have been updated successfully."
echo "GitHub Actions should now be able to assume these roles using OIDC authentication."
