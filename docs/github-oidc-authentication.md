# GitHub Authentication and OIDC: How It All Works Together

This document explains how GitHub authentication, organizations, and OpenID Connect (OIDC) work together in our infrastructure setup.

## 1. Personal GitHub User vs. Organization

- **Personal GitHub User**: This is your individual GitHub account that you use to log in to GitHub.
- **GitHub Organization**: This is a shared account (e.g., "datascientest-fastAPI-project-group-25") where multiple users can collaborate on multiple repositories.
- **Relationship**: Your personal user is a member of the organization with certain permissions (likely admin or owner).

## 2. OIDC (OpenID Connect) Authentication

OIDC is being used in our infrastructure for two main purposes:

### A. GitHub Actions to AWS Authentication

- **What it does**: Allows GitHub Actions workflows to authenticate with AWS without storing long-lived credentials.
- **How it works**:
  1. We've set up an AWS IAM OIDC provider that trusts GitHub's OIDC provider (`token.actions.githubusercontent.com`).
  2. We've created an IAM role (`github-actions-dev`) that can be assumed by GitHub Actions workflows.
  3. When a GitHub Actions workflow runs, it gets a short-lived token from GitHub's OIDC provider.
  4. This token is used to assume the IAM role in AWS, granting temporary AWS credentials.
  5. The workflow can then interact with AWS resources using these temporary credentials.

### B. EKS to AWS Authentication

- **What it does**: Allows Kubernetes service accounts to authenticate with AWS services.
- **How it works**:
  1. The EKS cluster has an OIDC provider associated with it.
  2. Service accounts in Kubernetes can be annotated with IAM roles.
  3. When a pod uses such a service account, it can access AWS services using the permissions of the associated IAM role.

## 3. How They All Work Together

### For Development/Deployment

- You (as your personal user) push code to the organization's repository.
- GitHub Actions workflows run in the context of the organization.
- These workflows use OIDC to authenticate with AWS without needing stored credentials.
- The workflows can then deploy resources to AWS, including updating the EKS cluster.

### For Application Runtime

- Your application runs in pods in the EKS cluster.
- These pods use Kubernetes service accounts that are annotated with IAM roles.
- The pods can access AWS services (like ECR for container images) using these IAM roles.
- External Secrets Operator uses this mechanism to fetch secrets from AWS Secrets Manager.

### For ArgoCD GitOps

- ArgoCD is configured to watch your release repository.
- When changes are pushed to the release repository, ArgoCD detects them.
- ArgoCD pulls the Helm charts and applies them to the cluster.
- ArgoCD uses the Kubernetes service account we created to access AWS resources if needed.

## 4. Authentication Flow Diagram

```
┌─────────────────┐     Push Code     ┌─────────────────────┐
│                 │ ───────────────► │                     │
│  Personal User  │                   │  GitHub Repository  │
│                 │ ◄─────────────── │                     │
└─────────────────┘   Authentication  └─────────────────────┘
                                               │
                                               │ Trigger
                                               ▼
┌─────────────────┐                  ┌─────────────────────┐
│                 │                   │                     │
│   AWS Account   │ ◄───────────────►│   GitHub Actions    │
│                 │      OIDC Auth    │                     │
└─────────────────┘                  └─────────────────────┘
        │                                      │
        │ Deploy                               │ Deploy
        ▼                                      ▼
┌─────────────────┐                  ┌─────────────────────┐
│                 │                   │                     │
│   EKS Cluster   │ ◄───────────────►│      ArgoCD         │
│                 │    K8s Resources  │                     │
└─────────────────┘                  └─────────────────────┘
```

## 5. Authentication Methods for Different Operations

| Operation | Authentication Method | Credentials Used |
|-----------|------------------------|-----------------|
| Git Push/Pull | Personal GitHub Token or SSH Key | Your personal GitHub credentials |
| GitHub Actions | OIDC | Temporary AWS credentials via IAM role |
| EKS Access | AWS CLI + `aws eks update-kubeconfig` | Your AWS user credentials |
| Pod AWS Access | IRSA (IAM Roles for Service Accounts) | Pod service account + EKS OIDC provider |

## 6. Best Practices

1. **Never store AWS credentials in GitHub repositories**
   - Use OIDC for GitHub Actions workflows
   - Store sensitive values in AWS Secrets Manager or as GitHub Secrets

2. **Use least privilege permissions**
   - IAM roles should have only the permissions they need
   - Kubernetes RBAC should be properly configured

3. **Rotate credentials regularly**
   - Personal access tokens should be rotated periodically
   - Use short-lived credentials whenever possible

4. **Audit access regularly**
   - Review who has access to GitHub repositories
   - Review IAM roles and their permissions
