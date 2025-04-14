#!/bin/bash

# Script to check ArgoCD login functionality

echo "Checking ArgoCD login functionality..."

# Check if Argo CD is installed
if ! kubectl get ns argocd &> /dev/null; then
    echo "Error: Argo CD namespace not found. Please install Argo CD first."
    exit 1
fi

# Check Argo CD pods
echo "Checking Argo CD pods..."
PODS=$(kubectl get pods -n argocd)
if [[ $PODS =~ "Running" ]]; then
    echo "✅ Argo CD pods are running"
else
    echo "❌ Error: Argo CD pods are not running"
    echo "$PODS"
    exit 1
fi

# Check Argo CD server status
echo "Checking Argo CD server..."
STATUS=$(kubectl get svc -n argocd argocd-server)
if [[ $STATUS =~ "LoadBalancer" ]]; then
    echo "✅ Argo CD server is running as LoadBalancer"
    SERVER_URL=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    echo "   ArgoCD URL: http://$SERVER_URL"
else
    echo "❌ Error: Argo CD server is not running as LoadBalancer"
    echo "$STATUS"
    exit 1
fi

# Check for argocd-secret
echo "Checking ArgoCD secret..."
if kubectl get secret -n argocd argocd-secret &> /dev/null; then
    echo "✅ ArgoCD secret exists"
    
    # Check if admin.password is set in the secret
    if kubectl get secret -n argocd argocd-secret -o jsonpath='{.data.admin\.password}' &> /dev/null; then
        echo "✅ Admin password is set in argocd-secret"
    else
        echo "❌ Warning: Admin password not found in argocd-secret"
    fi
else
    echo "❌ Error: ArgoCD secret not found"
fi

# Check for initial admin secret
echo "Checking initial admin secret..."
if kubectl get secret -n argocd argocd-initial-admin-secret &> /dev/null; then
    echo "✅ Initial admin secret exists"
    INITIAL_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "   Initial admin password: $INITIAL_PASSWORD"
else
    echo "ℹ️ Initial admin secret not found (this is normal if a custom password is set)"
fi

# Check ArgoCD server logs for login-related issues
echo "Checking ArgoCD server logs for login-related issues..."
LOGIN_ISSUES=$(kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=100 | grep -i "login\|auth\|password\|credential" | grep -i "error\|fail\|invalid")
if [ -n "$LOGIN_ISSUES" ]; then
    echo "❌ Warning: Found login-related issues in ArgoCD logs"
    echo "$LOGIN_ISSUES"
else
    echo "✅ No login-related issues found in logs"
fi

echo ""
echo "Login Instructions:"
echo "1. Access ArgoCD at: http://$SERVER_URL"
echo "2. Username: admin"
echo "3. Password: admin123 (as set in argocd-values.yml)"
echo ""
echo "If you still can't log in, try redeploying ArgoCD with:"
echo "./redeploy-argocd.sh development"
