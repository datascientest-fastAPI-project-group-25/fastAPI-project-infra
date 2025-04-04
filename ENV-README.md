# Environment Variables Structure

This document describes the structure of environment variables used in this project.

## Overview

The project uses a hierarchical approach to environment variables, allowing for common settings to be shared across environments while still supporting environment-specific overrides.

## File Structure

### Root Directory

- `.env.base`: Common settings for all environments
- `.env.<environment>`: Environment-specific settings (e.g., `.env.dev`, `.env.test`, `.env.local-test`)

### Bootstrap Directory

- `bootstrap/.env.base`: Common settings for all bootstrap operations
- `bootstrap/.env.<environment>`: Environment-specific settings for bootstrap operations (e.g., `bootstrap/.env.bootstrap`)

## Loading Order

When running operations, environment variables are loaded in the following order:

1. `.env.base` (common settings for all environments)
2. `.env.<environment>` (environment-specific settings)
3. `bootstrap/.env.base` (common bootstrap settings)
4. `bootstrap/.env.<environment>` (bootstrap-specific settings)

Variables defined in later files will override those defined in earlier files.

## Setting Up Your Environment

1. Copy the example files to create your environment files:
   ```bash
   cp .env.base.example .env.base
   cp .env.dev.example .env.dev
   cp bootstrap/.env.base.example bootstrap/.env.base
   cp bootstrap/.env.bootstrap.example bootstrap/.env.bootstrap
   ```

2. Edit the files to set your environment-specific values:
   - `.env.base`: Set your AWS credentials, account ID, and project name
   - `.env.dev`: Set your AWS region and environment
   - `bootstrap/.env.base`: Set your bootstrap resource names
   - `bootstrap/.env.bootstrap`: Set your bootstrap environment and AWS region

## Environment Types

### Development (dev)

For local development work. Use:
- `.env.base`
- `.env.dev`

### Testing (test)

For running tests. Use:
- `.env.base`
- `.env.test`

### Local Testing (local-test)

For testing with GitHub Actions locally using act. Use:
- `.env.base`
- `.env.local-test`

### Bootstrap

For setting up the initial infrastructure. Use:
- `.env.base`
- `.env.bootstrap`
- `bootstrap/.env.base`
- `bootstrap/.env.bootstrap`

## Example Variables

### Common Variables (`.env.base`)

```
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_ACCOUNT_ID=your-aws-account-id
PROJECT_NAME=fastapi-project
```

### Environment-Specific Variables (`.env.<environment>`)

```
AWS_DEFAULT_REGION=eu-west-2
ENVIRONMENT=dev
```

### Bootstrap-Specific Variables (`bootstrap/.env.bootstrap`)

```
ENVIRONMENT=bootstrap
AWS_DEFAULT_REGION=us-east-1
```
