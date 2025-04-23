#!/bin/bash

# Script to check ArgoCD installation

# Check if environment is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Environment can be: development, staging, production"
    exit 1
fi

ENVIRONMENT=$1

echo "Checking ArgoCD installation in $ENVIRONMENT environment..."

# Get the ArgoCD namespace
NAMESPACE="argocd-$ENVIRONMENT"

echo "Checking ArgoCD namespace..."
kubectl get namespace $NAMESPACE

echo "Checking ArgoCD pods..."
kubectl get pods -n $NAMESPACE

echo "Checking ArgoCD services..."
kubectl get services -n $NAMESPACE

echo "Checking ArgoCD deployments..."
kubectl get deployments -n $NAMESPACE

echo "Checking ArgoCD statefulsets..."
kubectl get statefulsets -n $NAMESPACE

echo "Checking ArgoCD configmaps..."
kubectl get configmaps -n $NAMESPACE

echo "Checking ArgoCD secrets..."
kubectl get secrets -n $NAMESPACE

echo "Checking ArgoCD applications..."
kubectl get applications -n $NAMESPACE

echo "Checking ArgoCD projects..."
kubectl get appprojects -n $NAMESPACE

echo "ArgoCD installation check complete!"
