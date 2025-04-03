# Load environment variables
load_env:
	@echo "Loading environment variables..."

# GitHub Actions Testing (shortcuts to bootstrap makefile)
act_bootstrap: load_env
	@cd bootstrap && make act-bootstrap

act_terraform: load_env
	@cd bootstrap && make act-terraform

act_mock: load_env
	@cd bootstrap && make act-mock

# Check GitHub Actions setup
check_gh:
	@echo "Checking GitHub Actions setup..."
	@command -v gh >/dev/null 2>&1 || { echo "GitHub CLI (gh) is not installed. Please install it first."; exit 1; }
	@gh auth status || { echo "Please login to GitHub using 'gh auth login'"; exit 1; }

# Check GitHub secrets
check_secrets: check_gh
	@echo "Checking required GitHub secrets..."
	@gh secret list 2>/dev/null | grep -q "AWS_ACCESS_KEY_ID" || echo "Missing: AWS_ACCESS_KEY_ID"
	@gh secret list 2>/dev/null | grep -q "AWS_SECRET_ACCESS_KEY" || echo "Missing: AWS_SECRET_ACCESS_KEY"
	@gh secret list 2>/dev/null | grep -q "AWS_ACCOUNT_ID" || echo "Missing: AWS_ACCOUNT_ID"

# Set required GitHub secrets
set_secrets: check_gh
	@echo "Setting required GitHub secrets from environment variables..."
	@test -n "$$AWS_ACCESS_KEY_ID" || { echo "AWS_ACCESS_KEY_ID environment variable not set"; exit 1; }
	@test -n "$$AWS_SECRET_ACCESS_KEY" || { echo "AWS_SECRET_ACCESS_KEY environment variable not set"; exit 1; }
	@test -n "$$AWS_ACCOUNT_ID" || { echo "AWS_ACCOUNT_ID environment variable not set"; exit 1; }
	@gh secret set AWS_ACCESS_KEY_ID --body "$$AWS_ACCESS_KEY_ID"
	@gh secret set AWS_SECRET_ACCESS_KEY --body "$$AWS_SECRET_ACCESS_KEY"
	@gh secret set AWS_ACCOUNT_ID --body "$$AWS_ACCOUNT_ID"
	@echo "GitHub secrets have been set successfully"

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

# Verify local setup
verify_local:
	@echo "Verifying local environment..."
	@test -f .env || { echo "Missing .env file"; exit 1; }
	@test -f .env.local-test || { echo "Missing .env.local-test file"; exit 1; }

.PHONY: load_env act_bootstrap act_terraform act_mock check_gh check_secrets set_secrets verify_local \
	tf_init tf_fmt tf_validate tf_security tf_state_setup tf_init_aws tf_migrate_state migrate \
	tf_plan tf_apply terraform tf_destroy
