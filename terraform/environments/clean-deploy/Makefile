# Makefile for FastAPI Project Infrastructure

.PHONY: init-dev plan-dev apply-dev destroy-dev
.PHONY: init-staging plan-staging apply-staging destroy-staging
.PHONY: init-prod plan-prod apply-prod destroy-prod
.PHONY: clean help

# Development Environment
init-dev:
cd development && terraform init

plan-dev:
cd development && terraform plan -var-file=terraform.tfvars

apply-dev:
cd development && terraform apply -var-file=terraform.tfvars -auto-approve

destroy-dev:
cd development && terraform destroy -var-file=terraform.tfvars -auto-approve

# Staging Environment
init-staging:
cd staging && terraform init

plan-staging:
cd staging && terraform plan -var-file=terraform.tfvars

apply-staging:
cd staging && terraform apply -var-file=terraform.tfvars -auto-approve

destroy-staging:
cd staging && terraform destroy -var-file=terraform.tfvars -auto-approve

# Production Environment
init-prod:
cd production && terraform init

plan-prod:
cd production && terraform plan -var-file=terraform.tfvars

apply-prod:
cd production && terraform apply -var-file=terraform.tfvars -auto-approve

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
@echo "  init-dev           Initialize development environment"
@echo "  plan-dev           Plan changes for development environment"
@echo "  apply-dev          Apply changes to development environment"
@echo "  destroy-dev        Destroy development environment"
@echo "  init-staging       Initialize staging environment"
@echo "  plan-staging       Plan changes for staging environment"
@echo "  apply-staging      Apply changes to staging environment"
@echo "  destroy-staging    Destroy staging environment"
@echo "  init-prod          Initialize production environment"
@echo "  plan-prod          Plan changes for production environment"
@echo "  apply-prod         Apply changes to production environment"
@echo "  destroy-prod       Destroy production environment"
@echo "  clean              Clean up Terraform files"
@echo "  help               Show this help message"
