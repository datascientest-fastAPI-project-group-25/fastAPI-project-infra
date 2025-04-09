#!/bin/bash
set -e

# This script registers an external EKS cluster with ArgoCD
# Usage: ./register-cluster.sh <cluster_name> <cluster_endpoint> <cluster_ca_data> <token>

CLUSTER_NAME=$1
CLUSTER_ENDPOINT=$2
CLUSTER_CA_DATA=$3
TOKEN=$4

if [ -z "$CLUSTER_NAME" ] || [ -z "$CLUSTER_ENDPOINT" ] || [ -z "$CLUSTER_CA_DATA" ] || [ -z "$TOKEN" ]; then
  echo "Usage: ./register-cluster.sh <cluster_name> <cluster_endpoint> <cluster_ca_data> <token>"
  exit 1
fi

# Create a temporary kubeconfig file for the cluster
KUBECONFIG_FILE=$(mktemp)
cat > $KUBECONFIG_FILE << EOF
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    server: ${CLUSTER_ENDPOINT}
    certificate-authority-data: ${CLUSTER_CA_DATA}
contexts:
- name: ${CLUSTER_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    user: ${CLUSTER_NAME}
current-context: ${CLUSTER_NAME}
users:
- name: ${CLUSTER_NAME}
  user:
    token: ${TOKEN}
EOF

# Register the cluster with ArgoCD
argocd cluster add ${CLUSTER_NAME} --kubeconfig $KUBECONFIG_FILE --yes

# Clean up
rm $KUBECONFIG_FILE
