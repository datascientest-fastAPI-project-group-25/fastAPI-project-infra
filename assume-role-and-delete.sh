#!/bin/bash

# Script to assume the FastAPIProjectInfraRole and delete the dev2 EKS cluster

# Set environment variables
export AWS_DEFAULT_REGION=us-east-1
export PROJECT_NAME=fastapi-project
export ENVIRONMENT=dev2
export CLUSTER_NAME=${PROJECT_NAME}-eks-${ENVIRONMENT}
export ROLE_ARN=arn:aws:iam::575977136211:role/FastAPIProjectInfraRole

echo "Assuming role: $ROLE_ARN"
echo "Target cluster: $CLUSTER_NAME"

# Assume the role and get temporary credentials
TEMP_CREDS=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name DeleteClusterSession)

if [ $? -ne 0 ]; then
    echo "Error: Failed to assume role"
    exit 1
fi

# Extract credentials from the response
export AWS_ACCESS_KEY_ID=$(echo $TEMP_CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $TEMP_CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $TEMP_CREDS | jq -r '.Credentials.SessionToken')

# Verify the assumed role
echo "Verifying assumed role credentials..."
aws sts get-caller-identity

if [ $? -ne 0 ]; then
    echo "Error: Failed to verify assumed role credentials"
    exit 1
fi

# Delete the EKS cluster
echo "Deleting EKS cluster: $CLUSTER_NAME"
aws eks delete-cluster --name $CLUSTER_NAME

echo "Cluster deletion initiated. This may take 10-15 minutes to complete."
echo "You can check the status with: aws eks describe-cluster --name $CLUSTER_NAME"
