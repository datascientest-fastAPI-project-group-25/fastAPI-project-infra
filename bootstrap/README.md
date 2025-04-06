# Bootstrap Environments

This directory contains the bootstrap environments for the FastAPI project infrastructure. The bootstrap environments are used to set up the initial infrastructure required for the project.

## Dockerized Environments

The bootstrap environments have been dockerized to ensure they can run on any system. The following environments are available:

1. **AWS Environment**: Used to set up infrastructure in AWS
2. **Localstack Environment**: Used to set up infrastructure locally using Localstack

## Prerequisites

- Docker
- Docker Compose

## Usage

### Building the Docker Images

```bash
cd bootstrap
make docker-build
```

### AWS Environment

To start the AWS environment:

```bash
cd bootstrap
make docker-aws
```

This will start a Docker container with the AWS environment and open a bash shell. From there, you can run AWS CLI commands and Terraform commands.

To set up the Terraform state resources in AWS:

```bash
cd bootstrap
make docker-aws-setup-state
```

To run a bootstrap dryrun in AWS:

```bash
cd bootstrap
make docker-aws-bootstrap-dryrun
```

### Localstack Environment

To start the Localstack environment:

```bash
cd bootstrap
make docker-localstack
```

This will start a Docker container with the Localstack environment and open a bash shell. From there, you can run AWS CLI commands and Terraform commands against Localstack.

To run a bootstrap dryrun in Localstack:

```bash
cd bootstrap
make docker-localstack-bootstrap-dryrun
```

### Testing the Environments

To test both environments:

```bash
cd bootstrap
make docker-test
```

This will run a test script that builds the Docker images, runs the bootstrap dryrun for both environments, and cleans up the Docker resources.

### Cleaning Up

To clean up the Docker resources:

```bash
cd bootstrap
make docker-clean
```

## Environment Variables

The Docker containers use environment variables for configuration. The following environment variables are used:

### AWS Environment

#### Authentication Methods

The bootstrap environment supports two authentication methods for AWS:

1. **Role-Based Authentication (Recommended)**
2. **User-Based Authentication (Legacy)**

#### Role-Based Authentication

Role-based authentication uses AWS IAM roles to provide temporary credentials, which is more secure and easier to manage across multiple users and machines. This approach is recommended for team environments.

Required environment variables:
- `AWS_ACCOUNT_ID`: Your AWS account ID
- `AWS_BOOTSTRAP_ROLE_NAME`: Name of the IAM role to assume (default: FastAPIProjectBootstrapInfraRole)
- `AWS_DEFAULT_REGION`: AWS region (default: us-east-1)

To use role-based authentication:

1. Ensure the role exists in your AWS account with appropriate permissions
2. Set up your AWS CLI with credentials that have permission to assume the role
3. Set the required environment variables

```bash
export AWS_ACCOUNT_ID=your-account-id
export AWS_BOOTSTRAP_ROLE_NAME=FastAPIProjectBootstrapInfraRole
```

The bootstrap script will automatically attempt to assume the role if `AWS_BOOTSTRAP_ROLE_NAME` is set.

#### User-Based Authentication (Legacy)

If you prefer to use direct AWS credentials:

- `AWS_ACCESS_KEY_ID`: AWS access key ID (default: dummy-key)
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key (default: dummy-secret)
- `AWS_DEFAULT_REGION`: AWS region (default: us-east-1)
- `AWS_ACCOUNT_ID`: AWS account ID (default: 000000000000)
- `PROJECT_NAME`: Project name (default: fastapi-project)
- `ENVIRONMENT`: Environment name (default: dev)

> **Note**: For actual AWS operations to succeed, you need to set real AWS credentials. The default values are provided only to prevent warnings when running Docker Compose commands without setting these environment variables. They won't allow actual AWS operations to succeed.

You can set these environment variables in several ways:

1. **Environment variables in your shell**:
   ```bash
   export AWS_ACCESS_KEY_ID=your-access-key
   export AWS_SECRET_ACCESS_KEY=your-secret-key
   export AWS_ACCOUNT_ID=your-account-id
   ```

2. **Create a .env file**:
   ```bash
   # Create a .env file in the bootstrap directory
   echo "AWS_ACCESS_KEY_ID=your-access-key" > .env
   echo "AWS_SECRET_ACCESS_KEY=your-secret-key" >> .env
   echo "AWS_ACCOUNT_ID=your-account-id" >> .env
   ```

3. **Copy and modify the example files**:
   ```bash
   # Copy the example files and modify them with your credentials
   cp .env.base.example .env.base
   # Edit .env.base with your credentials
   ```

### Localstack Environment

- `AWS_ACCESS_KEY_ID`: AWS access key ID (default: test)
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key (default: test)
- `AWS_DEFAULT_REGION`: AWS region (default: eu-west-2)
- `AWS_ACCOUNT_ID`: AWS account ID (default: 000000000000)
- `PROJECT_NAME`: Project name (default: fastapi-project)
- `ENVIRONMENT`: Environment name (default: dev)
- `LOCALSTACK_ENDPOINT`: Localstack endpoint (default: http://localstack:4566)

## Docker Compose

The Docker Compose file defines the following services:

1. `aws`: AWS environment
2. `localstack-env`: Localstack environment
3. `localstack`: Localstack service

The AWS environment mounts the local AWS credentials to allow access to AWS resources. The Localstack environment depends on the Localstack service and uses it for AWS emulation.
