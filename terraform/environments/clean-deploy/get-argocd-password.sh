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

# Try to get the password from the initial admin secret
PASSWORD=""

# Try multiple times as it might take some time for the secret to be created
for i in {1..5}; do
    if kubectl -n $NAMESPACE get secret argocd-initial-admin-secret &> /dev/null; then
        # Get the ArgoCD admin password from the initial admin secret
        PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
        if [ -n "$PASSWORD" ]; then
            echo "ArgoCD admin password (from initial admin secret): $PASSWORD"
            echo "Username: admin"
            break
        fi
    fi

    if [ $i -lt 5 ]; then
        echo "Waiting for the initial admin secret to be created... (attempt $i)"
        sleep 5
    fi
done

if [ -z "$PASSWORD" ]; then
    echo "Warning: Could not retrieve the initial admin password."
    echo "The secret might not have been created yet or might have been deleted."
    echo "Try again in a few moments or check the ArgoCD deployment status."
fi

# Additional instructions for accessing ArgoCD
echo ""
echo "To access ArgoCD UI:"
echo "1. Get the ArgoCD server URL:"
echo "   kubectl get svc -n $NAMESPACE argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo "2. Open the URL in your browser"
echo "3. Log in with the username and password above"
