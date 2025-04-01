# Bootstrap Infrastructure

This directory contains the infrastructure bootstrap code for setting up the foundational AWS resources needed for Terraform state management and CI/CD operations.

## Directory Structure

```
bootstrap/
├── environments/           # Environment-specific configurations
│   ├── local/             # LocalStack development setup
│   │   ├── main.tf        # Main LocalStack configuration
│   │   ├── variables.tf   # LocalStack-specific variables
│   │   └── outputs.tf     # LocalStack outputs
│   └── aws/               # AWS production bootstrap
│       ├── main.tf        # Main AWS configuration
│       ├── variables.tf   # AWS-specific variables
│       └── outputs.tf     # AWS outputs
├── modules/               # Reusable modules
│   ├── state/            # S3 state bucket + DynamoDB
│   ├── logging/          # Logging configuration
│   └── security/         # IAM roles and Lambda functions
└── README.md             # This file
```

## Modules

### State Module
- Manages S3 bucket for Terraform state
- Sets up DynamoDB for state locking
- Configures versioning and encryption

### Logging Module
- Creates and configures logging bucket
- Sets up bucket policies and lifecycle rules
- Manages access logging for state bucket

### Security Module
- Creates GitHub Actions OIDC provider and roles
- Sets up Lambda function for state change notifications
- Manages IAM policies and permissions

## Usage

### Local Development (with LocalStack)

1. Start LocalStack:
```bash
docker run --rm -p 4566:4566 -p 4571:4571 localstack/localstack
```

2. Initialize and apply local configuration:
```bash
cd environments/local
terraform init
terraform apply
```

### AWS Deployment

1. Configure AWS credentials:
```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_REGION="your_region"
```

2. Initialize and apply AWS configuration:
```bash
cd environments/aws
terraform init
terraform apply
```

## Important Notes

- The AWS environment requires an AWS account and appropriate credentials
- The local environment uses LocalStack and simulates AWS services
- Both environments use the same underlying modules but with different configurations
- The AWS environment includes additional security measures not present in local setup

## Environment-Specific Features

### Local Environment
- Uses LocalStack for AWS service simulation
- Creates local directories to simulate S3 buckets
- Simplified security configuration
- Suitable for development and testing

### AWS Environment
- Full AWS service integration
- Enhanced security measures
- Complete monitoring and logging setup
- Production-grade infrastructure