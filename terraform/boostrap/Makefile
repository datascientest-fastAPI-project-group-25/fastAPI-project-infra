# Load environment variables from .env.test
load_env:
	@echo "Loading environment variables..."
	@set -a && source "$(shell pwd)/.env.test" && set +a || echo "Warning: .env.test file not found or not accessible"

# Initialize Terraform
tf_init:
	@echo "Initializing Terraform..."
	terraform init -reconfigure -backend-config=terraform/backend.hcl

# Format Terraform files
tf_fmt:
	terraform fmt

# Validate Terraform configuration
tf_validate:
	terraform validate

# Plan Terraform changes
tf_plan:
	@echo "Planning Terraform changes..."
	terraform plan -out=tfplan -var="use_localstack=$(USE_LOCALSTACK)"

# Apply Terraform changes
tf_apply:
	@echo "Applying Terraform changes..."
	terraform apply -auto-approve -var="use_localstack=$(USE_LOCALSTACK)"

# Complete Terraform workflow
terraform: tf_init tf_validate tf_plan tf_apply

# Destroy infrastructure
tf_destroy:
	@echo "Destroying infrastructure..."
	terraform destroy -var="use_localstack=$(USE_LOCALSTACK)"

# Run security scan with Checkov
tf_security:
	bash checkov.sh

# Create S3 bucket and DynamoDB table for Terraform state
tf_state_setup:
	@echo "Setting up Terraform state infrastructure..."
	@cd terraform && \
	mv backend.tf backend.tf.bak 2>/dev/null || true && \
	terraform init && \
	terraform apply -auto-approve -var="use_localstack=$(USE_LOCALSTACK)" && \
	mv backend.tf.bak backend.tf && \
	echo "Terraform state has been successfully migrated to S3!"

# Initialize Terraform with AWS backend
tf_init_aws:
	terraform init -reconfigure -backend-config=terraform/backend.hcl

# Migrate local state to S3
tf_migrate_state:
	terraform state push local.tfstate

# Complete migration process
migrate: tf_state_setup tf_init_aws tf_migrate_state

# Default to local development
USE_LOCALSTACK ?= true
