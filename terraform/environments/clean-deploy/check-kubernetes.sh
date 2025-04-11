#!/bin/bash

# Script to check Kubernetes configuration

echo "Checking Kubernetes configuration..."
kubectl config get-contexts

echo "Checking Kubernetes version..."
kubectl version --short

echo "Checking Kubernetes nodes..."
kubectl get nodes

echo "Checking Kubernetes namespaces..."
kubectl get namespaces

echo "Checking Kubernetes pods..."
kubectl get pods --all-namespaces

echo "Checking Kubernetes services..."
kubectl get services --all-namespaces

echo "Checking Kubernetes deployments..."
kubectl get deployments --all-namespaces

echo "Checking Kubernetes statefulsets..."
kubectl get statefulsets --all-namespaces

echo "Checking Kubernetes daemonsets..."
kubectl get daemonsets --all-namespaces

echo "Checking Kubernetes configmaps..."
kubectl get configmaps --all-namespaces

echo "Checking Kubernetes secrets..."
kubectl get secrets --all-namespaces

echo "Kubernetes configuration check complete!"
