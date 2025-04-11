#!/bin/bash

# Script to check AWS credentials and permissions

echo "Checking AWS credentials..."
aws sts get-caller-identity

echo "Checking EKS permissions..."
aws eks list-clusters

echo "Checking EC2 permissions..."
aws ec2 describe-vpcs --query 'Vpcs[0]' --output json

echo "Checking RDS permissions..."
aws rds describe-db-instances --query 'DBInstances[0]' --output json

echo "Checking IAM permissions..."
aws iam list-roles --query 'Roles[0]' --output json

echo "Checking S3 permissions..."
aws s3 ls

echo "AWS credentials and permissions check complete!"
