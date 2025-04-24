# Terraform Deployment Scripts

This directory contains scripts for deploying and destroying infrastructure using Terraform.

## Scripts

### `deploy-with-target.sh`

This script deploys infrastructure using the `-target` approach to resolve `for_each` errors. It deploys infrastructure in two steps:

1. First, it deploys only the resources that the `for_each` depends on (IAM roles, etc.)
2. Then, it deploys the rest of the infrastructure

This approach resolves the "Invalid for_each argument" error that occurs when Terraform can't determine the keys for a `for_each` map during the planning phase.

#### Usage

```bash
./deploy-with-target.sh <environment> [aws_account_id] [aws_region]
```

Example:
```bash
./deploy-with-target.sh stg 123456789012 us-east-1
```

Valid environments: `stg`, `prod`

### `destroy-with-target.sh`

This script destroys infrastructure using the `-target` approach to resolve `for_each` errors. It destroys infrastructure in three steps:

1. First, it destroys most resources
2. Then, it specifically targets and destroys the resources that the `for_each` depends on (IAM roles, etc.)
3. Finally, it runs a verification destroy to ensure everything is gone

#### Usage

```bash
./destroy-with-target.sh <environment> [aws_account_id] [aws_region]
```

Example:
```bash
./destroy-with-target.sh stg 123456789012 us-east-1
```

Valid environments: `stg`, `prod`

## Common Issues

### "Invalid for_each argument" Error

This error occurs when Terraform can't determine the keys for a `for_each` map during the planning phase. The error message looks like:

```
The "for_each" map includes keys derived from resource attributes that
cannot be determined until apply, and so Terraform cannot determine the
full set of keys that will identify the instances of this resource.
```

The scripts in this directory use the `-target` approach to resolve this error by first deploying/destroying the resources that the `for_each` depends on, and then deploying/destroying the rest of the infrastructure.

## Environment Variables

The scripts use the following environment variables:

- `AWS_ACCOUNT_ID`: The AWS account ID to use for deployment
- `AWS_DEFAULT_REGION`: The AWS region to use for deployment

These can also be provided as command-line arguments.
