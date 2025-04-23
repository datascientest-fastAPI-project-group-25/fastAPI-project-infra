#!/bin/bash

# Script to port-forward ArgoCD UI

# Check if environment is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Environment can be: development, staging, production"
    exit 1
fi

ENVIRONMENT=$1

echo "Port-forwarding ArgoCD UI for $ENVIRONMENT environment..."

# Get the ArgoCD namespace
NAMESPACE="argocd-$ENVIRONMENT"

# Port-forward the ArgoCD server
kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443

echo "ArgoCD UI is available at: https://localhost:8080"
echo "Use 'admin' as the username and the password from get-argocd-password.sh"
