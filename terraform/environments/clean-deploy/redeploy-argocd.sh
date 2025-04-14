#!/bin/bash

# Script to redeploy ArgoCD with the new configuration

# Check if environment is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Environment can be: development, staging, production"
    exit 1
fi

ENVIRONMENT=$1

echo "Redeploying ArgoCD for $ENVIRONMENT environment..."

# Navigate to the environment directory
cd "$(dirname "$0")/$ENVIRONMENT" || {
    echo "Failed to navigate to environment directory"
    exit 1
}

# Initialize Terraform
echo "Initializing Terraform..."
terraform init \
  -backend-config="bucket=fastapi-project-terraform-state-575977136211" \
  -backend-config="key=fastapi/infra/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-state-lock-dev"

# Apply only the ArgoCD module
echo "Redeploying ArgoCD..."
terraform apply -target=module.argocd -var-file=terraform.tfvars

echo "ArgoCD redeployment complete!"
echo "You can now access ArgoCD with the following credentials:"
echo "Username: admin"
echo "Password: admin123"

# Get the ArgoCD server URL
echo "Getting ArgoCD server URL..."
ARGOCD_SERVER=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "ArgoCD server URL: http://$ARGOCD_SERVER"
