# Load environment variables from .env.test
load_env:
	@echo "Loading environment variables..."
	@set -a && source "$(shell pwd)/.env.test" && set +a || echo "Warning: .env.test file not found or not accessible"

# Run GitHub Actions locally with act (note: OIDC won't work locally)
run_act: load_env
	act -j terraform -W .github/workflows/local-test.yml

# Initialize Terraform
tf_init: load_env
	terraform init -reconfigure -backend-config=terraform/backend.tf

# Format Terraform files
tf_fmt: load_env
	terraform fmt

# Validate Terraform configuration
tf_validate: load_env
	terraform validate

# Run security scan with Checkov
tf_security: load_env
	bash checkov.sh

# Create S3 bucket and DynamoDB table for Terraform state
tf_state_setup: load_env
	@echo "Setting up Terraform state infrastructure..."
	@cd terraform && \
	mv backend.tf backend.tf.bak 2>/dev/null || true && \
	terraform init -reconfigure && \
	terraform apply -auto-approve && \
	mv backend.tf.bak backend.tf 2>/dev/null || true && \
	terraform init -migrate-state && \
	echo "Terraform state has been successfully migrated to S3!"

# Initialize Terraform with AWS backend
tf_init_aws: load_env
	terraform init -reconfigure -backend-config=terraform/backend.hcl

# Migrate local state to S3
tf_migrate_state: load_env
	terraform state push local.tfstate

# Complete migration process
migrate: load_env tf_state_setup tf_init_aws tf_migrate_state

# Plan Terraform changes
tf_plan: load_env
	@cd terraform && terraform plan -out=tfplan

# Apply Terraform changes
tf_apply: load_env
	@cd terraform && terraform apply -auto-approve

# Complete Terraform workflow
terraform: load_env tf_init tf_validate tf_plan tf_apply

# Destroy infrastructure
tf_destroy: load_env tf_init_aws
	terraform destroy
