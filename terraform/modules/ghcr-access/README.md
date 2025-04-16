# GitHub Container Registry Access Module

This module creates Kubernetes resources for accessing GitHub Container Registry (GHCR).

## Resources Created

1. **Kubernetes Secret**
   - Docker registry credentials for GHCR
   - Authentication for pulling private images

2. **Service Account**
   - Service account for pods to use the secret
   - Image pull secrets configuration

## Usage

```hcl
module "ghcr_access" {
  source = "../../modules/ghcr-access"

  namespace       = "default"
  github_token    = var.github_token
  github_username = "github-username"
  secret_name     = "ghcr-secret"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Kubernetes namespace to create the secret in | `string` | n/a | yes |
| github_token | GitHub personal access token or PAT | `string` | n/a | yes |
| github_username | GitHub username or organization | `string` | n/a | yes |
| secret_name | Name of the Kubernetes secret | `string` | `"ghcr-secret"` | no |
| service_account_name | Name of the service account | `string` | `"ghcr-service-account"` | no |
| create_service_account | Whether to create a service account | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| secret_name | Name of the created Kubernetes secret |
| service_account_name | Name of the created service account |
| namespace | Namespace where the resources are created |
