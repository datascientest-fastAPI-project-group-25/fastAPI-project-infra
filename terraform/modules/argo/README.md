# ArgoCD Module

This module deploys ArgoCD to an EKS cluster for GitOps-based continuous delivery.

## Resources Created

1. **ArgoCD Helm Release**
   - Deploys ArgoCD using the official Helm chart
   - Configures ArgoCD with custom values

2. **ArgoCD Application**
   - Deploys an ArgoCD Application resource
   - Points to the specified Git repository

## Usage

```hcl
module "argocd" {
  source = "../../modules/argo"

  depends_on = [
    module.eks,
    module.k8s_resources
  ]
}
```

## Configuration

The ArgoCD configuration is defined in the `argocd-values.yml` file. Key configurations include:

- **Admin Password**: Set to `password` in plain text
- **Service Type**: LoadBalancer for external access
- **Insecure Mode**: Enabled for easier access (disable in production)
- **Git Repository**: Configured to use the project's release repository

## Accessing ArgoCD

### Using the LoadBalancer URL

1. Get the LoadBalancer URL:
   ```bash
   kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
   ```

2. Open the URL in your browser

3. Log in with:
   - Username: `admin`
   - Password: `admin123`

### Using Port Forwarding

1. Run the port-forward script:
   ```bash
   ./port-forward-argocd.sh <environment>
   ```

2. Open https://localhost:8080 in your browser

3. Log in with:
   - Username: `admin`
   - Password: `password`

## Troubleshooting

### Login Issues

If you can't log in with the default credentials:

1. Check if the ArgoCD server is running:
   ```bash
   kubectl get pods -n argocd
   ```

2. Check the ArgoCD server logs:
   ```bash
   kubectl logs -n argocd deployment/argocd-server
   ```

3. Try resetting the admin password:
   ```bash
   kubectl -n argocd patch secret argocd-secret \
     -p '{"stringData": {"admin.password": "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa", "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
   ```
   This sets the password to `admin123` (using a bcrypt hash)

4. Restart the ArgoCD server:
   ```bash
   kubectl rollout restart deployment argocd-server -n argocd
   ```

## Security Considerations

For production environments, consider:

1. Disabling insecure mode
2. Using HTTPS with proper certificates
3. Integrating with an external identity provider (OIDC, LDAP, etc.)
4. Setting a stronger admin password
