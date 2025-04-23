# Terraform Workflow Changes

## Overview

This document describes the changes made to the Terraform workflow to ensure that:

1. Final deployment only runs on merge of PR to main
2. Authentication and prerequisite checks happen before deployment
3. We can verify we are "deployment ready" before merging to main

## Changes Made

### 1. Updated Workflow Triggers

Added comments to clarify the purpose of each trigger:

```yaml
on:
  # Only run deployment on merge of PR to main
  push:
    branches:
      - main
  # Run validation and planning on PRs to main
  pull_request:
    branches:
      - main
```

### 2. Added Authentication Verification Step

Added a dedicated step to verify AWS authentication and permissions during PR validation:

```yaml
# Verify AWS authentication and permissions during PR
- name: Verify AWS Authentication and Permissions - PR
  if: github.event_name == 'pull_request'
  run: |
    echo "Verifying AWS authentication and permissions..."
    aws sts get-caller-identity
    
    # Check if we have the necessary permissions for deployment
    for env in stg prod; do
      echo "Checking permissions for $env environment..."
      aws s3 ls s3://fastapi-project-terraform-state-${AWS_ACCOUNT_ID}/fastapi/infra/$env/ || echo "Warning: Cannot access state bucket for $env"
      aws dynamodb describe-table --table-name terraform-state-lock-$env || echo "Warning: Cannot access state lock table for $env"
    done
```

### 3. Enhanced PR Validation

Added Terraform validation step and success message to PR validation:

```yaml
terraform validate
# ...
echo "✅ All environments validated and planned successfully. Ready for deployment!"
```

### 4. PR Merge Detection

Added a step to detect if a push to main is from a PR merge:

```yaml
# Check if this is a PR merge to main
- name: Check if PR merge
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  id: check_pr_merge
  run: |
    # Get the commit message
    COMMIT_MSG=$(git log -1 --pretty=format:%s)
    echo "Commit message: $COMMIT_MSG"
    
    # Check if it's a merge commit from a PR
    if [[ "$COMMIT_MSG" == "Merge pull request"* ]]; then
      echo "is_pr_merge=true" >> $GITHUB_OUTPUT
      echo "✅ This is a PR merge commit"
    else
      echo "is_pr_merge=false" >> $GITHUB_OUTPUT
      echo "⚠️ This is not a PR merge commit, skipping deployment"
    fi
```

### 5. Conditional Deployment

Modified the deployment step to only run if the push is from a PR merge:

```yaml
# Initialize and apply for production only on merge of PR to main
- name: Deploy to Production
  if: github.event_name == 'push' && github.ref == 'refs/heads/main' && steps.check_pr_merge.outputs.is_pr_merge == 'true'
```

## Testing

Added comprehensive testing capabilities:

1. Created test scripts and configuration for local testing with `act`
2. Added sample event files to simulate different scenarios:
   - PR to main
   - PR merge to main
   - Direct push to main
3. Created a script to push changes and monitor workflow execution

## How to Test

1. Use the local testing script:
   ```bash
   cd tests/act
   chmod +x test-terraform-workflow.sh
   ./test-terraform-workflow.sh
   ```

2. Push changes and create PR:
   ```bash
   cd tests/act
   chmod +x push-and-monitor.sh
   ./push-and-monitor.sh
   ```

## Expected Behavior

1. **PR to main**: 
   - Runs authentication checks
   - Validates Terraform configuration
   - Creates plans for both environments
   - Does NOT run deployment

2. **PR merge to main**:
   - Detects that it's a PR merge
   - Runs deployment to production

3. **Direct push to main**:
   - Detects that it's not a PR merge
   - Skips deployment