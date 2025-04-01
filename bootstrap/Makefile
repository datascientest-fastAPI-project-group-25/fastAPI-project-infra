# Helper functions for AWS validation
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
        $(error Environment variable $1$(if $2, ($2)) is not set))

# GitHub Actions local testing with act
.PHONY: act-bootstrap act-terraform

act-bootstrap:
	@if [ ! -f "../.env.local-test" ]; then \
		echo "Error: .env.local-test file not found in root directory"; \
		exit 1; \
	fi
	@echo "Testing bootstrap job locally with act..."
	@cd .. && act -j bootstrap -W .github/workflows/terraform-bootstrap.yml \
		--secret-file .env.local-test \
		--container-architecture linux/amd64 --bind

act-terraform:
	@if [ ! -f "../.env.local-test" ]; then \
		echo "Error: .env.local-test file not found in root directory"; \
		exit 1; \
	fi
	@echo "Testing terraform job locally with act..."
	@cd .. && act -j terraform -W .github/workflows/terraform-bootstrap.yml \
		--secret-file .env.local-test \
		--container-architecture linux/amd64 --bind

# Environment validation for AWS operations
validate-aws-env:
	$(call check_defined, AWS_ACCESS_KEY_ID, AWS access key)
	$(call check_defined, AWS_SECRET_ACCESS_KEY, AWS secret key)
	$(call check_defined, AWS_DEFAULT_REGION, AWS region)

# LocalStack targets
.PHONY: local-init local-plan local-apply local-destroy start-localstack stop-localstack

start-localstack:
	@echo "Starting LocalStack..."
	docker run -d --name localstack -p 4566:4566 -p 4571:4571 localstack/localstack
	@echo "Waiting for LocalStack to be ready..."
	@sleep 10
	@cd environments/local && ./init-localstack.sh

stop-localstack:
	@echo "Stopping LocalStack..."
	docker stop localstack || true
	docker rm localstack || true

local-init:
	@echo "Initializing Terraform for local environment..."
	cd environments/local && terraform init

local-plan: start-localstack
	@echo "Planning local environment changes..."
	cd environments/local && terraform plan

local-apply:
	@echo "Applying local environment changes..."
	cd environments/local && terraform apply

local-destroy:
	@echo "Destroying local environment..."
	cd environments/local && terraform destroy

# AWS targets
.PHONY: aws-init aws-plan aws-apply aws-destroy aws-test aws-setup-state aws-apply-bootstrap

aws-test: validate-aws-env
	@echo "Testing AWS bootstrap configuration..."
	cd environments/aws && ./test-bootstrap.sh

aws-prepare: validate-aws-env
	@echo "Preparing AWS environment..."
	cd environments/aws && ./package-lambda.sh

aws-setup-state: validate-aws-env
	@echo "Setting up Terraform state resources in AWS..."
	cd environments/aws && ./setup-state-bucket.sh

aws-apply-bootstrap: validate-aws-env
	@echo "Applying bootstrap resources to AWS (skipping state resources)..."
	cd environments/aws && ./apply-bootstrap.sh

aws-init: validate-aws-env aws-prepare
	@echo "Initializing Terraform for AWS environment..."
	cd environments/aws && terraform init

aws-plan: validate-aws-env
	@echo "Planning AWS environment changes..."
	cd environments/aws && terraform plan

aws-apply: validate-aws-env
	@echo "Applying AWS environment changes..."
	cd environments/aws && terraform apply

aws-destroy: validate-aws-env
	@echo "Destroying AWS environment..."
	cd environments/aws && terraform destroy

# Combined targets
.PHONY: clean

clean:
	@echo "Cleaning up..."
	find . -type d -name ".terraform" -exec rm -rf {} +
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "terraform.tfstate*" -delete

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo ""
	@echo "GitHub Actions Testing:"
	@echo "  act-bootstrap    - Test bootstrap job locally with act"
	@echo "  act-terraform    - Test terraform job locally with act"
	@echo ""
	@echo "Setup:"
	@echo "  aws-prepare     - Package Lambda function for AWS deployment"
	@echo "Local Environment:"
	@echo "  start-localstack  - Start LocalStack container"
	@echo "  stop-localstack   - Stop LocalStack container"
	@echo "  local-init       - Initialize Terraform for local environment"
	@echo "  local-plan       - Plan changes for local environment"
	@echo "  local-apply      - Apply changes to local environment"
	@echo "  local-destroy    - Destroy local environment"
	@echo ""
	@echo "AWS Environment:"
	@echo "  aws-test         - Test bootstrap configuration (creates and destroys resources)"
	@echo "  aws-setup-state  - Set up S3 bucket and DynamoDB table for Terraform state"
	@echo "  aws-apply-bootstrap - Apply bootstrap resources (skipping state resources)"
	@echo "  aws-init         - Initialize Terraform for AWS environment"
	@echo "  aws-plan         - Plan changes for AWS environment"
	@echo "  aws-apply        - Apply changes to AWS environment"
	@echo "  aws-destroy      - Destroy AWS environment"
	@echo ""
	@echo "Other:"
	@echo "  clean            - Clean up Terraform files"
	@echo "  help             - Show this help message"