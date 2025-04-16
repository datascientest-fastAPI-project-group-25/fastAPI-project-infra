# External Secrets Module

This module installs and configures the External Secrets Operator in a Kubernetes cluster.

## Resources Created

1. **Helm Release**
   - External Secrets Operator Helm chart
   - Configuration for AWS Secrets Manager integration

2. **Kubernetes Resources**
   - ClusterSecretStore for AWS Secrets Manager
   - ServiceAccount for External Secrets Operator
   - RBAC roles and role bindings

## Usage

```hcl
module "external_secrets" {
  source = "../../modules/external-secrets"

  eks_cluster_id  = module.eks.cluster_id
  service_account_name = "external-secrets"
  namespace       = "external-secrets"
  region          = var.aws_region
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| eks_cluster_id | ID of the EKS cluster | `string` | n/a | yes |
| service_account_name | Name of the service account for External Secrets | `string` | `"external-secrets"` | no |
| namespace | Namespace to install External Secrets Operator | `string` | `"external-secrets"` | no |
| region | AWS region for Secrets Manager | `string` | n/a | yes |
| chart_version | Version of the External Secrets Operator Helm chart | `string` | `"0.9.0"` | no |
| create_namespace | Whether to create the namespace | `bool` | `true` | no |
| service_account_annotations | Annotations for the service account | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace where External Secrets Operator is installed |
| service_account_name | Name of the service account for External Secrets |
| helm_release_name | Name of the Helm release |
| helm_release_version | Version of the Helm release |
