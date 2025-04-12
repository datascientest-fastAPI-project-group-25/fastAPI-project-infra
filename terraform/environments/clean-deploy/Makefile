# Makefile for FastAPI Project Infrastructure with Staged Deployment

.PHONY: init-dev plan-dev apply-dev destroy-dev
.PHONY: init-staging plan-staging apply-staging destroy-staging
.PHONY: init-prod plan-prod apply-prod destroy-prod
.PHONY: clean help

# Development Environment - Staged Deployment
init-dev:
	cd development && terraform init

# VPC Stage
plan-dev-vpc:
	cd development && terraform plan -var-file=terraform.tfvars -target=module.vpc

apply-dev-vpc:
	cd development && terraform apply -var-file=terraform.tfvars -target=module.vpc -auto-approve

# Security Stage
plan-dev-security:
	cd development && terraform plan -var-file=terraform.tfvars -target=module.security

apply-dev-security:
	cd development && terraform apply -var-file=terraform.tfvars -target=module.security -auto-approve

# EKS Stage
plan-dev-eks:
	cd development && terraform plan -var-file=terraform.tfvars -target=module.eks

apply-dev-eks:
	cd development && terraform apply -var-file=terraform.tfvars -target=module.eks -auto-approve

# K8s Resources Stage
plan-dev-k8s:
	cd development && terraform plan -var-file=terraform.tfvars -target=module.k8s_resources

apply-dev-k8s:
	cd development && terraform apply -var-file=terraform.tfvars -target=module.k8s_resources -auto-approve

# ArgoCD Stage
plan-dev-argocd:
	cd development && terraform plan -var-file=terraform.tfvars -target=module.argocd

apply-dev-argocd:
	cd development && terraform apply -var-file=terraform.tfvars -target=module.argocd -auto-approve

# External Secrets Stage
plan-dev-external-secrets:
	cd development && terraform plan -var-file=terraform.tfvars -target=module.external_secrets

apply-dev-external-secrets:
	cd development && terraform apply -var-file=terraform.tfvars -target=module.external_secrets -auto-approve

# GHCR Access Stage
plan-dev-ghcr:
	cd development && terraform plan -var-file=terraform.tfvars -target=module.ghcr_access

apply-dev-ghcr:
	cd development && terraform apply -var-file=terraform.tfvars -target=module.ghcr_access -auto-approve

# Full Development Environment
plan-dev:
	cd development && terraform plan -var-file=terraform.tfvars

apply-dev: apply-dev-vpc apply-dev-security apply-dev-eks apply-dev-k8s apply-dev-argocd apply-dev-external-secrets apply-dev-ghcr
	@echo "Development environment fully deployed"

destroy-dev:
	cd development && terraform destroy -var-file=terraform.tfvars -auto-approve

# Staging Environment - Staged Deployment
init-staging:
	cd staging && terraform init

# VPC Stage
plan-staging-vpc:
	cd staging && terraform plan -var-file=terraform.tfvars -target=module.vpc

apply-staging-vpc:
	cd staging && terraform apply -var-file=terraform.tfvars -target=module.vpc -auto-approve

# Security Stage
plan-staging-security:
	cd staging && terraform plan -var-file=terraform.tfvars -target=module.security

apply-staging-security:
	cd staging && terraform apply -var-file=terraform.tfvars -target=module.security -auto-approve

# EKS Stage
plan-staging-eks:
	cd staging && terraform plan -var-file=terraform.tfvars -target=module.eks

apply-staging-eks:
	cd staging && terraform apply -var-file=terraform.tfvars -target=module.eks -auto-approve

# K8s Resources Stage
plan-staging-k8s:
	cd staging && terraform plan -var-file=terraform.tfvars -target=module.k8s_resources

apply-staging-k8s:
	cd staging && terraform apply -var-file=terraform.tfvars -target=module.k8s_resources -auto-approve

# ArgoCD Stage
plan-staging-argocd:
	cd staging && terraform plan -var-file=terraform.tfvars -target=module.argocd

apply-staging-argocd:
	cd staging && terraform apply -var-file=terraform.tfvars -target=module.argocd -auto-approve

# External Secrets Stage
plan-staging-external-secrets:
	cd staging && terraform plan -var-file=terraform.tfvars -target=module.external_secrets

apply-staging-external-secrets:
	cd staging && terraform apply -var-file=terraform.tfvars -target=module.external_secrets -auto-approve

# GHCR Access Stage
plan-staging-ghcr:
	cd staging && terraform plan -var-file=terraform.tfvars -target=module.ghcr_access

apply-staging-ghcr:
	cd staging && terraform apply -var-file=terraform.tfvars -target=module.ghcr_access -auto-approve

# Full Staging Environment
plan-staging:
	cd staging && terraform plan -var-file=terraform.tfvars

apply-staging: apply-staging-vpc apply-staging-security apply-staging-eks apply-staging-k8s apply-staging-argocd apply-staging-external-secrets apply-staging-ghcr
	@echo "Staging environment fully deployed"

destroy-staging:
	cd staging && terraform destroy -var-file=terraform.tfvars -auto-approve

# Production Environment - Staged Deployment
init-prod:
	cd production && terraform init

# VPC Stage
plan-prod-vpc:
	cd production && terraform plan -var-file=terraform.tfvars -target=module.vpc

apply-prod-vpc:
	cd production && terraform apply -var-file=terraform.tfvars -target=module.vpc -auto-approve

# Security Stage
plan-prod-security:
	cd production && terraform plan -var-file=terraform.tfvars -target=module.security

apply-prod-security:
	cd production && terraform apply -var-file=terraform.tfvars -target=module.security -auto-approve

# EKS Stage
plan-prod-eks:
	cd production && terraform plan -var-file=terraform.tfvars -target=module.eks

apply-prod-eks:
	cd production && terraform apply -var-file=terraform.tfvars -target=module.eks -auto-approve

# K8s Resources Stage
plan-prod-k8s:
	cd production && terraform plan -var-file=terraform.tfvars -target=module.k8s_resources

apply-prod-k8s:
	cd production && terraform apply -var-file=terraform.tfvars -target=module.k8s_resources -auto-approve

# ArgoCD Stage
plan-prod-argocd:
	cd production && terraform plan -var-file=terraform.tfvars -target=module.argocd

apply-prod-argocd:
	cd production && terraform apply -var-file=terraform.tfvars -target=module.argocd -auto-approve

# External Secrets Stage
plan-prod-external-secrets:
	cd production && terraform plan -var-file=terraform.tfvars -target=module.external_secrets

apply-prod-external-secrets:
	cd production && terraform apply -var-file=terraform.tfvars -target=module.external_secrets -auto-approve

# GHCR Access Stage
plan-prod-ghcr:
	cd production && terraform plan -var-file=terraform.tfvars -target=module.ghcr_access

apply-prod-ghcr:
	cd production && terraform apply -var-file=terraform.tfvars -target=module.ghcr_access -auto-approve

# Full Production Environment
plan-prod:
	cd production && terraform plan -var-file=terraform.tfvars

apply-prod: apply-prod-vpc apply-prod-security apply-prod-eks apply-prod-k8s apply-prod-argocd apply-prod-external-secrets apply-prod-ghcr
	@echo "Production environment fully deployed"

destroy-prod:
	cd production && terraform destroy -var-file=terraform.tfvars -auto-approve

# Clean up
clean:
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name ".terraform.lock.hcl" -type f -delete
	find . -name "terraform.tfstate*" -type f -delete

# Help
help:
	@echo "Available targets:"
	@echo "  init-dev                  Initialize development environment"
	@echo "  plan-dev-vpc              Plan VPC changes for development environment"
	@echo "  apply-dev-vpc             Apply VPC changes to development environment"
	@echo "  plan-dev-security         Plan security changes for development environment"
	@echo "  apply-dev-security        Apply security changes to development environment"
	@echo "  plan-dev-eks              Plan EKS changes for development environment"
	@echo "  apply-dev-eks             Apply EKS changes to development environment"
	@echo "  plan-dev-k8s              Plan K8s resources changes for development environment"
	@echo "  apply-dev-k8s             Apply K8s resources changes to development environment"
	@echo "  plan-dev-argocd           Plan ArgoCD changes for development environment"
	@echo "  apply-dev-argocd          Apply ArgoCD changes to development environment"
	@echo "  plan-dev-external-secrets Plan External Secrets changes for development environment"
	@echo "  apply-dev-external-secrets Apply External Secrets changes to development environment"
	@echo "  plan-dev-ghcr             Plan GHCR Access changes for development environment"
	@echo "  apply-dev-ghcr            Apply GHCR Access changes to development environment"
	@echo "  plan-dev                  Plan all changes for development environment"
	@echo "  apply-dev                 Apply all changes to development environment"
	@echo "  destroy-dev               Destroy development environment"
	@echo ""
	@echo "  init-staging              Initialize staging environment"
	@echo "  plan-staging-vpc          Plan VPC changes for staging environment"
	@echo "  apply-staging-vpc         Apply VPC changes to staging environment"
	@echo "  plan-staging-security     Plan security changes for staging environment"
	@echo "  apply-staging-security    Apply security changes to staging environment"
	@echo "  plan-staging-eks          Plan EKS changes for staging environment"
	@echo "  apply-staging-eks         Apply EKS changes to staging environment"
	@echo "  plan-staging-k8s          Plan K8s resources changes for staging environment"
	@echo "  apply-staging-k8s         Apply K8s resources changes to staging environment"
	@echo "  plan-staging-argocd       Plan ArgoCD changes for staging environment"
	@echo "  apply-staging-argocd      Apply ArgoCD changes to staging environment"
	@echo "  plan-staging-external-secrets Plan External Secrets changes for staging environment"
	@echo "  apply-staging-external-secrets Apply External Secrets changes to staging environment"
	@echo "  plan-staging-ghcr         Plan GHCR Access changes for staging environment"
	@echo "  apply-staging-ghcr        Apply GHCR Access changes to staging environment"
	@echo "  plan-staging              Plan all changes for staging environment"
	@echo "  apply-staging             Apply all changes to staging environment"
	@echo "  destroy-staging           Destroy staging environment"
	@echo ""
	@echo "  init-prod                 Initialize production environment"
	@echo "  plan-prod-vpc             Plan VPC changes for production environment"
	@echo "  apply-prod-vpc            Apply VPC changes to production environment"
	@echo "  plan-prod-security        Plan security changes for production environment"
	@echo "  apply-prod-security       Apply security changes to production environment"
	@echo "  plan-prod-eks             Plan EKS changes for production environment"
	@echo "  apply-prod-eks            Apply EKS changes to production environment"
	@echo "  plan-prod-k8s             Plan K8s resources changes for production environment"
	@echo "  apply-prod-k8s            Apply K8s resources changes to production environment"
	@echo "  plan-prod-argocd          Plan ArgoCD changes for production environment"
	@echo "  apply-prod-argocd         Apply ArgoCD changes to production environment"
	@echo "  plan-prod-external-secrets Plan External Secrets changes for production environment"
	@echo "  apply-prod-external-secrets Apply External Secrets changes to production environment"
	@echo "  plan-prod-ghcr            Plan GHCR Access changes for production environment"
	@echo "  apply-prod-ghcr           Apply GHCR Access changes to production environment"
	@echo "  plan-prod                 Plan all changes for production environment"
	@echo "  apply-prod                Apply all changes to production environment"
	@echo "  destroy-prod              Destroy production environment"
	@echo ""
	@echo "  clean                     Clean up Terraform files"
	@echo "  help                      Show this help message"
