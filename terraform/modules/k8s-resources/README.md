# Kubernetes Resources Module

This module creates various Kubernetes resources using the Kubernetes provider.

## Resources Created

1. **Namespaces**
   - Namespaces for different applications and environments
   - Labels and annotations for namespace organization

2. **Service Accounts**
   - Service accounts for applications
   - RBAC roles and role bindings

3. **ConfigMaps**
   - Configuration data for applications
   - Environment-specific configurations

4. **Secrets**
   - Sensitive data for applications
   - Credentials and tokens

## Usage

```hcl
module "k8s_resources" {
  source = "../../modules/k8s-resources"

  project_name    = var.project_name
  environment     = var.environment
  eks_cluster_id  = module.eks.cluster_id
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name (development, staging, production) | `string` | n/a | yes |
| eks_cluster_id | ID of the EKS cluster | `string` | n/a | yes |
| namespaces | List of namespaces to create | `list(string)` | `[]` | no |
| service_accounts | Map of service accounts to create | `map(object)` | `{}` | no |
| config_maps | Map of ConfigMaps to create | `map(object)` | `{}` | no |
| secrets | Map of Secrets to create | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespaces | List of created namespaces |
| service_accounts | Map of created service accounts |
| config_maps | Map of created ConfigMaps |
| secrets | Map of created Secrets |
