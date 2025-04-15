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
NAMESPACE="argocd"

# Check if the initial admin secret exists
if kubectl -n $NAMESPACE get secret argocd-initial-admin-secret &> /dev/null; then
    # Get the ArgoCD admin password from the initial admin secret
    PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "ArgoCD admin password (from initial admin secret): $PASSWORD"
    echo "Username: admin"
else
    # If the initial admin secret doesn't exist, the password is set in the values file
    echo "ArgoCD admin password: password (set in argocd-values.yml)"
    echo "Username: admin"
fi

# Additional instructions for accessing ArgoCD
echo ""
echo "To access ArgoCD UI:"
echo "1. Get the ArgoCD server URL:"
echo "   kubectl get svc -n $NAMESPACE argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo "2. Open the URL in your browser"
echo "3. Log in with the username and password above"
