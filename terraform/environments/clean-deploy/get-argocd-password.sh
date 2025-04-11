#!/bin/bash

# Script to get ArgoCD password

# Check if environment is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Environment can be: development, staging, production"
    exit 1
fi

ENVIRONMENT=$1

echo "Getting ArgoCD password for $ENVIRONMENT environment..."

# Get the ArgoCD namespace
NAMESPACE="argocd-$ENVIRONMENT"

# Get the ArgoCD admin password
PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "ArgoCD admin password: $PASSWORD"
