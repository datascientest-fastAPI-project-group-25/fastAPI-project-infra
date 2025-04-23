# Testing GitHub Actions Workflows with Act

This directory contains scripts and configuration files for testing GitHub Actions workflows locally using [act](https://github.com/nektos/act).

## Prerequisites

1. Install act:
   ```bash
   # macOS
   brew install act

   # Linux
   curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
   ```

2. Create a `.env.act` file with your secrets:
   ```bash
   cp .env.act.example .env.act
   # Edit .env.act with your actual secrets
   ```

## Test Files

- **Event JSON files**: Simulate different GitHub events
  - `pr-event.json`: Simulates a pull request event
  - `pr-merge-event.json`: Simulates a push event from a PR merge
  - `direct-push-event.json`: Simulates a direct push to main

- **Test script**:
  - `test-terraform-workflow.sh`: Tests the Terraform workflow under different scenarios

## Running Tests

1. Make the test script executable:
   ```bash
   chmod +x test-terraform-workflow.sh
   ```

2. Run the test script:
   ```bash
   ./test-terraform-workflow.sh
   ```

## Expected Behavior

1. **PR Validation**: When a PR is opened to main, the workflow should:
   - Run authentication checks
   - Validate Terraform configuration
   - Create plans for both staging and production
   - NOT run any deployments

2. **PR Merge to Main**: When a PR is merged to main, the workflow should:
   - Detect that it's a PR merge commit
   - Run the deployment to production

3. **Direct Push to Main**: When code is pushed directly to main (not via PR), the workflow should:
   - Detect that it's not a PR merge commit
   - Skip the deployment step

## Troubleshooting

- If you encounter permission issues with act, try running with sudo
- Make sure your `.env.act` file contains all required secrets
- Check that Docker is running (act requires Docker)