#!/bin/bash

# Script to destroy and redeploy ArgoCD

echo "This script will destroy the current ArgoCD deployment and redeploy it with the new configuration."
echo "Press Enter to continue or Ctrl+C to cancel..."
read

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in the PATH"
    exit 1
fi

# Check if we have access to the Kubernetes cluster
if ! kubectl get nodes &> /dev/null; then
    echo "Error: Cannot access Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

# Step 1: Delete the current ArgoCD deployment
echo "Step 1: Deleting the current ArgoCD deployment..."
kubectl delete namespace argocd --wait=true

# Wait for the namespace to be fully deleted
echo "Waiting for the argocd namespace to be fully deleted..."
while kubectl get namespace argocd &> /dev/null; do
    echo "Namespace argocd still exists, waiting..."
    sleep 5
done
echo "Namespace argocd has been deleted."

# Step 2: Create a new argocd namespace
echo "Step 2: Creating a new argocd namespace..."
kubectl create namespace argocd

# Step 3: Deploy ArgoCD using Helm
echo "Step 3: Deploying ArgoCD using Helm..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create a values file with our custom configuration
echo "Creating values file..."
cat > argocd-values.yaml << EOF
server:
  service:
    type: LoadBalancer  
  ingress:
    enabled: true

  extraArgs:
    - --insecure

configs:
  cm:
    application.instanceLabelKey: argocd.argoproj.io/instance
    kustomize.buildOptions: "--enable-helm"
    repositories: |
      - url: https://github.com/datascientest-fastAPI-project-group-25/fastAPI-project-release

  secret:
    # Set ArgoCD admin password (plain text)
    argocdServerAdminPassword: admin123

  params:
    server.insecure: true

rbac:
  policy.default: role:readonly
  policy.csv: |
    g, system:authenticated, role:admin
EOF

# Install ArgoCD with our custom values
echo "Installing ArgoCD..."
helm install argocd argo/argo-cd --namespace argocd --values argocd-values.yaml --wait

# Step 4: Verify the deployment
echo "Step 4: Verifying the deployment..."
kubectl get pods -n argocd
kubectl get svc -n argocd

# Step 5: Get the ArgoCD server URL
echo "Step 5: Getting the ArgoCD server URL..."
ARGOCD_SERVER=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "ArgoCD server URL: http://$ARGOCD_SERVER"

# Step 6: Test the login
echo "Step 6: Testing the login..."
echo "You can now access ArgoCD with the following credentials:"
echo "Username: admin"
echo "Password: admin123"

# Clean up
rm argocd-values.yaml

echo "ArgoCD has been successfully redeployed!"
