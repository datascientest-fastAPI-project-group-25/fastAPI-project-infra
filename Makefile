# Load environment variables based on ENV variable (default: localstack_dev)
# Usage: make ENV=aws_dev tf_plan
#        make ENV=localstack_dev tf_plan
#        make ENV=test test
ENV ?= localstack_dev

# Export ENV so sub-processes/scripts can use it
export ENV

# Target to load environment variables using the script
load_env:
	@echo "Loading environment variables for ENV=$(ENV)..."
	@. bootstrap/scripts/load-env.sh

# --- GitHub Actions Local Testing (act) ---
# Requires act to be installed (https://github.com/nektos/act)
ACT_FLAGS ?= -W .github/workflows/ --container-architecture linux/amd64

act_bootstrap: load_env
	# Runs the bootstrap workflow locally
	@echo "Running bootstrap workflow locally for ENV=$(ENV)..."
	./tests/act/run-act-combined.sh normal bootstrap

act_terraform: load_env
	# Runs the terraform workflow locally
	@echo "Running terraform workflow locally for ENV=$(ENV)..."
	./tests/act/run-act-combined.sh normal terraform

act_mock: load_env
	# Runs the mock workflow locally
	@echo "Running mock workflow locally..."
	./tests/act/run-act-combined.sh mock

# --- Checks and Setup ---
check_gh:
	@command -v gh >/dev/null 2>&1 || { echo >&2 "GitHub CLI (gh) is not installed. Please install it (brew install gh). Aborting."; exit 1; }
	@gh auth status || { echo >&2 "Not logged into GitHub CLI. Please run 'gh auth login'. Aborting."; exit 1; }

check_secrets: check_gh
	@echo "Checking required GitHub secrets..."
	@# Add checks for secrets needed by your workflows (e.g., AWS creds if deploying to AWS)

set_secrets: check_secrets load_env
	@echo "Setting required GitHub secrets from environment variables..."
	@test -n "$$AWS_ACCESS_KEY_ID" || { echo "AWS_ACCESS_KEY_ID environment variable not set"; exit 1; }
	@test -n "$$AWS_SECRET_ACCESS_KEY" || { echo "AWS_SECRET_ACCESS_KEY environment variable not set"; exit 1; }
	@test -n "$$AWS_ACCOUNT_ID" || { echo "AWS_ACCOUNT_ID environment variable not set"; exit 1; }
	@gh secret set AWS_ACCESS_KEY_ID --body "$$AWS_ACCESS_KEY_ID"
	@gh secret set AWS_SECRET_ACCESS_KEY --body "$$AWS_SECRET_ACCESS_KEY"
	@gh secret set AWS_ACCOUNT_ID --body "$$AWS_ACCOUNT_ID"
	@echo "GitHub secrets set."

# --- Terraform Commands (using loaded env) ---
tf_init: load_env
	@echo "Running terraform init for ENV=$(ENV) in $(TF_DIR)..."
	cd $(TF_DIR) && terraform init -input=false

tf_fmt: load_env
	@echo "Running terraform fmt..."
	terraform fmt -recursive

tf_validate: load_env
	@echo "Running terraform validate for ENV=$(ENV) in $(TF_DIR)..."
	cd $(TF_DIR) && terraform validate

tf_security: load_env
	@echo "Running Checkov security scan..."
	checkov -d . --config-file .checkov.yaml
	@echo "Running TFLint..."
	tflint --init
	tflint --recursive

# --- Terraform State Management (Example for AWS S3 Backend) ---
# Assumes variables like TF_STATE_BUCKET, TF_STATE_KEY, TF_STATE_REGION are in the env files
TF_DIR := environments/$(ENV_TYPE)
TF_BACKEND_CONFIG := "-backend-config=bucket=$(TF_STATE_BUCKET) -backend-config=key=$(TF_STATE_KEY) -backend-config=region=$(TF_STATE_REGION)"

tf_state_setup: load_env
	@echo "Setting up Terraform backend for ENV=$(ENV)..."
	@# This might involve creating the S3 bucket and DynamoDB table if they don't exist
	@# Add relevant AWS CLI commands here if needed, using loaded credentials
	@echo "Terraform backend setup assumed complete (manual step or separate script recommended)."

# Specific init for AWS backend
tf_init_aws: load_env
	@echo "Initializing Terraform with AWS backend config for ENV=$(ENV)..."
	cd $(TF_DIR) && terraform init -input=false $(TF_BACKEND_CONFIG)

# Example state migration (use with caution)
tf_migrate_state: load_env
	@echo "Attempting state migration (ensure backend is configured)..."
	cd $(TF_DIR) && terraform init -input=false -migrate-state $(TF_BACKEND_CONFIG)

migrate: load_env tf_state_setup tf_init_aws tf_migrate_state
	@echo "State migration process complete for ENV=$(ENV)."

# --- Terraform Plan/Apply/Destroy (using loaded env) ---
tf_plan: load_env tf_init # Use basic init, backend config loaded from env
	@echo "Running terraform plan for ENV=$(ENV) in $(TF_DIR)..."
	cd $(TF_DIR) && terraform plan -input=false -out=tfplan

tf_apply: load_env tf_init
	@echo "Running terraform apply for ENV=$(ENV) in $(TF_DIR)..."
	cd $(TF_DIR) && terraform apply -input=false tfplan

terraform: load_env tf_init tf_validate tf_plan tf_apply
	@echo "Terraform workflow completed for ENV=$(ENV)."

tf_destroy: load_env tf_init_aws # Needs backend init for destroy
	@echo "Running terraform destroy for ENV=$(ENV) in $(TF_DIR)..."
	cd $(TF_DIR) && terraform destroy -auto-approve

# --- Local Setup Verification ---
verify_local:
	@echo "Verifying local environment setup..."
	@test -f bootstrap/.env.base.example || { echo "Missing bootstrap/.env.base.example file"; exit 1; }
	@test -f bootstrap/environments/localstack/.env.local.example || { echo "Missing bootstrap/environments/localstack/.env.local.example file"; exit 1; }
	@test -f bootstrap/environments/aws/.env.aws.example || { echo "Missing bootstrap/environments/aws/.env.aws.example file"; exit 1; }
	@test -f tests/.env.test.example || { echo "Missing tests/.env.test.example file"; exit 1; }
	@test -f tests/.env.local-test.example || { echo "Missing tests/.env.local-test.example file"; exit 1; }
	@echo "Required example environment files found."
	@echo "Please ensure you have created the actual .env files from these examples."

# --- Cleanup ---
clean:
	@echo "Cleaning up Terraform files..."
	find . -type f -name 'tfplan' -delete
	find . -type f -name '.terraform.lock.hcl' -delete
	find . -type d -name '.terraform' -prune -exec rm -rf {} +
	@echo "Cleanup complete."

# --- Git Operations ---
# Feature branch naming convention: feat/<feature-name> or fix/<fix-name>
.PHONY: git_feature git_fix git_commit git_push git_merge git_status

# Create a new feature branch
git_feature:
	@read -p "Enter feature name (without spaces, use hyphens): " feature_name; \
	git checkout -b feat/$$feature_name

# Create a new fix branch
git_fix:
	@read -p "Enter fix name (without spaces, use hyphens): " fix_name; \
	git checkout -b fix/$$fix_name

# Commit changes in logical groups
git_commit:
	@echo "Committing changes in logical groups"
	@echo "Available files to commit:"
	@git status --short
	@echo ""
	@read -p "Enter files to commit (space-separated, or '.' for all): " files; \
	if [ "$$files" = "." ]; then \
		git add .; \
	else \
		git add $$files; \
	fi; \
	echo "Files staged for commit:"; \
	git status --short; \
	read -p "Enter commit message: " message; \
	git commit -m "$$message"

# Push current branch to remote
git_push:
	@branch_name=$$(git symbolic-ref --short HEAD); \
	git push -u origin $$branch_name

# Merge current branch to main
git_merge_main:
	@branch_name=$$(git symbolic-ref --short HEAD); \
	echo "Merging $$branch_name to main branch"; \
	git checkout main; \
	git merge $$branch_name; \
	git push origin main; \
	git checkout $$branch_name

# Show git status
git_status:
	@git status

# --- Help ---
help:
	@echo "Usage: make [TARGET] [ENV=environment_stage]"
	@echo ""
	@echo "Targets:"
	@echo "  load_env          Loads environment variables based on ENV (default: localstack_dev)"
	@echo "  act_bootstrap     Run bootstrap GitHub Action workflow locally via act (uses tests/act/run-act-combined.sh)"
	@echo "  act_terraform     Run terraform GitHub Action workflow locally via act (uses tests/act/run-act-combined.sh)"
	@echo "  act_mock          Run mock GitHub Action workflow locally via act (uses tests/act/run-act-combined.sh)"
	@echo "  check_gh          Check if GitHub CLI is installed and authenticated"
	@echo "  check_secrets     Check for required GitHub secrets (basic)"
	@echo "  set_secrets       Set GitHub secrets from local environment variables (needs ENV loaded)"
	@echo "  tf_init           Initialize Terraform for the specified ENV"
	@echo "  tf_fmt            Format Terraform code"
	@echo "  tf_validate       Validate Terraform configuration for the specified ENV"
	@echo "  tf_security       Run Checkov and TFLint security checks"
	@echo "  tf_state_setup    (Placeholder) Ensure Terraform backend (e.g., S3 bucket) is ready"
	@echo "  tf_init_aws       Initialize Terraform with AWS S3 backend configuration"
	@echo "  tf_migrate_state  Attempt to migrate Terraform state to the configured backend"
	@echo "  migrate           Run full state migration process (setup, init, migrate)"
	@echo "  tf_plan           Generate Terraform execution plan for the specified ENV"
	@echo "  tf_apply          Apply Terraform changes for the specified ENV"
	@echo "  terraform         Run full Terraform workflow (init, validate, plan, apply)"
	@echo "  tf_destroy        Destroy Terraform-managed infrastructure for the specified ENV"
	@echo "  verify_local      Check if required example .env files exist"
	@echo "  clean             Remove temporary Terraform files (.terraform*, tfplan)"
	@echo "  help              Show this help message"
	@echo ""
	@echo "Git Operations:"
	@echo "  git_feature       Create a new feature branch (feat/<feature-name>)"
	@echo "  git_fix           Create a new fix branch (fix/<fix-name>)"
	@echo "  git_commit        Commit changes in logical groups (interactive)"
	@echo "  git_push          Push current branch to remote"
	@echo "  git_merge_main    Merge current branch to main branch"
	@echo "  git_status        Show git status"
	@echo ""
	@echo "Environment Variable (ENV):"
	@echo "  Set the target environment and stage. Examples:"
	@echo "    make tf_plan ENV=aws_dev       # Plan for AWS development environment"
	@echo "    make tf_apply ENV=localstack_dev # Apply for LocalStack development environment (default)"
	@echo "    make test ENV=test             # Run tests using tests/.env.test"
	@echo "    make act_mock ENV=local-test   # Run act mock test using tests/.env.local-test"
	@echo ""
	@echo "Default ENV is 'localstack_dev'"


.PHONY: load_env act_bootstrap act_terraform act_mock check_gh check_secrets set_secrets verify_local \
        tf_init tf_fmt tf_validate tf_security tf_state_setup tf_init_aws tf_migrate_state migrate \
        tf_plan tf_apply terraform tf_destroy clean help git_feature git_fix git_commit git_push git_merge_main git_status
