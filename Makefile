# Load environment variables from .env.test
load_env:
	set -o allexport; source .env.test; set +o allexport;

# Run GitHub Actions locally with act (note: OIDC won't work locally)
run_act: load_env
	act -j terraform -W .github/workflows/local-test.yml

# Initialize Terraform
tf_init: load_env
	terraform init -reconfigure

# Format Terraform files
tf_fmt: load_env
	terraform fmt

# Validate Terraform configuration
tf_validate: load_env
	terraform validate

# Run security scan with Checkov
tf_security: load_env
	bash checkov.sh

# Run Terraform plan
tf_plan: load_env
	terraform plan -out=tfplan

# Apply Terraform changes
tf_apply: load_env
	terraform apply -auto-approve tfplan

# Complete Terraform workflow
terraform: load_env tf_init tf_validate tf_plan tf_apply

# Destroy infrastructure
tf_destroy: load_env
	terraform destroy