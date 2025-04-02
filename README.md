# FastAPI Project Infrastructure

Infrastructure as Code (IaC) repository for managing the FastAPI project infrastructure using Terraform.

## Project Structure

```
.
├── bootstrap/           # Infrastructure bootstrap code
│   ├── environments/    # Environment-specific configurations
│   │   ├── local/      # LocalStack development setup
│   │   └── aws/        # AWS production bootstrap
│   ├── modules/        # Reusable Terraform modules
│   │   ├── state/      # State management (S3 + DynamoDB)
│   │   ├── logging/    # Logging infrastructure
│   │   └── security/   # IAM and Lambda resources
│   ├── Makefile        # Bootstrap automation commands
│   └── README.md       # Bootstrap documentation
│
├── terraform/          # Main infrastructure code
│   ├── modules/        # Shared Terraform modules
│   └── environments/   # Environment configurations
│
├── scripts/           # Utility scripts
│   ├── checkov.sh
│   ├── init-tflint.sh
│   └── setup_state.sh
│
├── Makefile           # Main automation commands
└── README.md         # This file
```

## Getting Started

### Local Development

1. Start LocalStack:
```bash
cd bootstrap/environments/local
make start-localstack
```

2. Initialize and apply bootstrap:
```bash
make local-init
make local-apply
```

### AWS Deployment

1. Configure AWS credentials:
```bash
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_REGION="your_region"
```

   For GitHub Actions, see [AWS Credentials Setup](docs/README-AWS-CREDENTIALS.md) for instructions on setting up AWS credentials as GitHub secrets.

2. Package Lambda and deploy bootstrap:
```bash
cd bootstrap/environments/aws
make aws-prepare
make aws-init
make aws-apply
```

## Development Workflow

1. Bootstrap infrastructure provides:
   - S3 bucket for Terraform state
   - DynamoDB table for state locking
   - Logging infrastructure
   - IAM roles and policies
   - Lambda for state change notifications

2. Main infrastructure uses the bootstrapped resources for:
   - State management
   - Access control
   - Resource organization

## Contributing

1. Create a new branch for your changes
2. Make your changes following the project structure
3. Test changes locally using LocalStack
4. Create a pull request for review

## Documentation

- [Bootstrap Documentation](bootstrap/README.md)
- [Terraform Documentation](terraform/README.md)
- [Scripts Documentation](scripts/README.md)
- [AWS Credentials Setup](docs/README-AWS-CREDENTIALS.md)

## License

See [LICENSE](LICENSE) file.
