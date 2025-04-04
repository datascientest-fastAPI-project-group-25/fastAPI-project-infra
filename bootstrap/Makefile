# Helper functions for AWS validation
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
        $(error Environment variable $1$(if $2, ($2)) is not set))

# GitHub Actions local testing with act
.PHONY: act-bootstrap act-terraform act-mock

act-bootstrap:
	@if [ ! -f "../tests/.env.local-test" ]; then \
		echo "Error: .env.local-test file not found in tests directory"; \
		exit 1; \
	fi
	@echo "Testing bootstrap job locally with act..."
	@cd .. && ./tests/act/run-act-combined.sh normal bootstrap

act-terraform:
	@if [ ! -f "../tests/.env.local-test" ]; then \
		echo "Error: .env.local-test file not found in tests directory"; \
		exit 1; \
	fi
	@echo "Testing terraform job locally with act..."
	@cd .. && ./tests/act/run-act-combined.sh normal terraform

act-mock:
	@if [ ! -f "../tests/.env.local-test" ]; then \
		echo "Error: .env.local-test file not found in tests directory"; \
		exit 1; \
	fi
	@echo "Testing workflow with mock AWS operations..."
	@cd .. && ./tests/act/run-act-combined.sh mock

# Load environment variables from .env files
load-env:
	@echo "Loading environment variables from .env files..."
	@bash -c "source scripts/load-env.sh"

# Environment validation for AWS operations
validate-aws-env: load-env
	$(call check_defined, AWS_ACCESS_KEY_ID, AWS access key)
	$(call check_defined, AWS_SECRET_ACCESS_KEY, AWS secret key)
	$(call check_defined, AWS_DEFAULT_REGION, AWS region)

# LocalStack targets
.PHONY: local-init local-plan local-apply local-destroy start-localstack stop-localstack localstack-bootstrap-dryrun

start-localstack:
	@echo "Starting LocalStack..."
	docker run -d --name localstack -p 4566:4566 -p 4571:4571 localstack/localstack
	@echo "Waiting for LocalStack to be ready..."
	@sleep 10
	@cd environments/localstack && ./init-localstack.sh

stop-localstack:
	@echo "Stopping LocalStack..."
	docker stop localstack || true
	docker rm localstack || true

local-init:
	@echo "Initializing Terraform for local environment..."
	cd environments/localstack && terraform init

local-plan: start-localstack
	@echo "Planning local environment changes..."
	cd environments/localstack && terraform plan

local-apply:
	@echo "Applying local environment changes..."
	cd environments/localstack && terraform apply

local-destroy:
	@echo "Destroying local environment..."
	cd environments/localstack && terraform destroy

localstack-bootstrap-dryrun:
	@echo "Running bootstrap dryrun in LocalStack (create, test, destroy bucket)..."
	cd environments/localstack && ./localstack-bootstrap-dryrun.sh

# AWS targets
.PHONY: load-env aws-init aws-plan aws-apply aws-destroy aws-setup-state aws-apply-bootstrap aws-bootstrap-dryrun

# aws-test: validate-aws-env
# 	@echo "Testing AWS bootstrap configuration..."
# 	cd environments/aws && ./test-bootstrap.sh

aws-prepare: validate-aws-env
	@echo "Preparing AWS environment..."
	cd environments/aws && ./package-lambda.sh

aws-setup-state: validate-aws-env
	@echo "Setting up Terraform state resources in AWS..."
	cd environments/aws && ./setup-state-bucket.sh

aws-apply-bootstrap: validate-aws-env
	@echo "Applying bootstrap resources to AWS (skipping state resources)..."
	cd environments/aws && ./apply-bootstrap.sh

aws-bootstrap-dryrun:
	@echo "Running bootstrap dryrun (create, test, destroy bucket in us-east-1)..."
	cd environments/aws && ./aws-bootstrap-dryrun.sh

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

# Docker targets
.PHONY: docker-build docker-aws docker-localstack docker-aws-setup-state docker-aws-bootstrap-dryrun docker-localstack-bootstrap-dryrun docker-clean docker-test

docker-build:
	@echo "Building Docker images..."
	docker-compose build

docker-aws:
	@echo "Starting AWS environment..."
	docker-compose run --rm aws bash

docker-localstack:
	@echo "Starting Localstack environment..."
	docker-compose up -d localstack
	@echo "Waiting for Localstack to be healthy (this may take a moment)..."
	@echo "Initializing Localstack resources..."
	docker-compose run --rm localstack-env ./init-localstack.sh
	docker-compose run --rm localstack-env bash

docker-aws-setup-state:
	@echo "Setting up Terraform state resources in AWS using Docker..."
	docker-compose run --rm aws ./setup-state-bucket.sh

docker-aws-bootstrap-dryrun:
	@echo "Running bootstrap dryrun in AWS using Docker..."
	docker-compose run --rm aws ./aws-bootstrap-dryrun.sh

docker-localstack-bootstrap-dryrun:
	@echo "Running bootstrap dryrun in Localstack using Docker..."
	docker-compose up -d localstack
	@echo "Waiting for Localstack to be healthy (this may take a moment)..."
	docker-compose run --rm localstack-env ./localstack-bootstrap-dryrun.sh

docker-clean:
	@echo "Cleaning up Docker resources..."
	docker-compose down -v

docker-test:
	@echo "Testing Docker environments..."
	./test-docker-environments.sh

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
	@echo "  act-bootstrap    - Test bootstrap job locally with act (uses tests/act/run-act-combined.sh)"
	@echo "  act-terraform    - Test terraform job locally with act (uses tests/act/run-act-combined.sh)"
	@echo "  act-mock        - Test workflow with mock AWS operations (uses tests/act/run-act-combined.sh) (recommended)"
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
	@echo "  localstack-bootstrap-dryrun - Create, test, and destroy bucket in LocalStack (dryrun)"
	@echo ""
	@echo "AWS Environment:"
	@echo "  aws-setup-state  - Set up S3 bucket and DynamoDB table for Terraform state"
	@echo "  aws-apply-bootstrap - Apply bootstrap resources (skipping state resources)"
	@echo "  aws-bootstrap-dryrun - Create, test, and destroy bucket in us-east-1 (dryrun)"
	@echo "  aws-init         - Initialize Terraform for AWS environment"
	@echo "  aws-plan         - Plan changes for AWS environment"
	@echo "  aws-apply        - Apply changes to AWS environment"
	@echo "  aws-destroy      - Destroy AWS environment"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build     - Build Docker images for AWS and Localstack environments"
	@echo "  docker-aws       - Start AWS environment in Docker and open a bash shell"
	@echo "  docker-localstack - Start Localstack environment in Docker and open a bash shell"
	@echo "  docker-aws-setup-state - Set up Terraform state resources in AWS using Docker"
	@echo "  docker-aws-bootstrap-dryrun - Run bootstrap dryrun in AWS using Docker"
	@echo "  docker-localstack-bootstrap-dryrun - Run bootstrap dryrun in Localstack using Docker"
	@echo "  docker-clean     - Clean up Docker resources"
	@echo "  docker-test      - Test both Docker environments"
	@echo ""
	@echo "Other:"
	@echo "  clean            - Clean up Terraform files"
	@echo "  help             - Show this help message"
