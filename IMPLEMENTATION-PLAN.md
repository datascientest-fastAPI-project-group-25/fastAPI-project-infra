# Implementation Plan: Migrating to Bun/TypeScript Workflow Utilities

This document outlines the plan for extracting inline scripts from GitHub Actions workflows into reusable TypeScript utilities using Bun.

## 1. Overview

### Current State
Our GitHub Actions workflows contain numerous inline bash scripts that handle various tasks:
- Environment determination
- Cache key generation
- Change detection
- PR merge detection
- Terraform operations
- PR body generation
- AWS authentication verification

These scripts are difficult to maintain, test, and reuse across workflows.

### Target State
A structured set of TypeScript utilities that:
- Are well-tested and type-safe
- Can be easily reused across workflows
- Are properly documented
- Can be executed with Bun for improved performance

## 2. Benefits of Bun/TypeScript Approach

### Advantages
1. **Type Safety**: TypeScript provides static typing, catching errors at compile time
2. **Improved Maintainability**: Clearer code structure, better error handling
3. **Testability**: Easier to write unit tests for isolated functions
4. **Reusability**: Functions can be imported across different utilities
5. **Performance**: Bun executes JavaScript/TypeScript significantly faster than Node.js
6. **Modern Development Experience**: Access to modern JS features and libraries
7. **Better JSON Handling**: Native JSON parsing and manipulation
8. **Simplified GitHub API Integration**: Using @actions/github library

### Potential Challenges
1. **Learning Curve**: Team members need to learn TypeScript and Bun
2. **Setup Overhead**: Initial setup requires additional configuration
3. **Workflow Changes**: Workflows need to be updated to use the new utilities
4. **Bun in CI**: Requires installing Bun in the CI environment

## 3. Implementation Phases

### Phase 1: Setup (Week 1)
1. Create utils directory structure
2. Set up package.json, tsconfig.json
3. Configure ESLint and Prettier
4. Set up testing framework
5. Create documentation templates

### Phase 2: Core Utilities (Week 2)
1. Implement environment determination utility
2. Implement PR merge detection utility
3. Implement cache key generation utility
4. Write tests for core utilities

### Phase 3: Terraform Utilities (Week 3)
1. Implement Terraform initialization utility
2. Implement Terraform plan utility
3. Implement Terraform apply utility
4. Write tests for Terraform utilities

### Phase 4: GitHub Utilities (Week 4)
1. Implement PR body generation utility
2. Implement branch detection utility
3. Implement PR comment utility
4. Write tests for GitHub utilities

### Phase 5: AWS Utilities (Week 5)
1. Implement AWS authentication verification utility
2. Implement AWS resource check utility
3. Write tests for AWS utilities

### Phase 6: Workflow Integration (Week 6)
1. Update terraform.yml workflow
2. Update terraform-bootstrap.yml workflow
3. Update create-pr.yml workflow
4. Test all workflows with act

## 4. Detailed Implementation Tasks

### For Each Utility:
1. Identify the inline script to extract
2. Define the TypeScript interface for inputs/outputs
3. Implement the utility function
4. Write unit tests
5. Document usage with examples
6. Update the workflow to use the utility

### Example: Environment Determination Utility
**Current (Bash):**
```bash
if [[ "${{ github.event.inputs.environment }}" != "" ]]; then
  echo "environment=${{ github.event.inputs.environment }}" >> $GITHUB_OUTPUT
  exit 0
fi

if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
  echo "environment=prod" >> $GITHUB_OUTPUT
else
  echo "environment=stg" >> $GITHUB_OUTPUT
fi
```

**Target (TypeScript):**
```typescript
export function determineEnvironment(options: EnvironmentOptions = {}): string {
  const {
    defaultEnv = 'stg',
    mainBranchEnv = 'prod',
    inputEnvName = 'environment'
  } = options;

  try {
    // Check for manual input from workflow_dispatch
    const manualInput = process.env[`INPUT_${inputEnvName.toUpperCase()}`];
    if (manualInput) {
      core.info(`Using manually specified environment: ${manualInput}`);
      return manualInput;
    }

    // Check branch context
    const ref = github.context.ref;
    if (ref === 'refs/heads/main') {
      core.info(`Detected main branch, using environment: ${mainBranchEnv}`);
      return mainBranchEnv;
    }

    // Default to staging for all other cases
    core.info(`Using default environment: ${defaultEnv}`);
    return defaultEnv;
  } catch (error) {
    if (error instanceof Error) {
      core.warning(`Error determining environment: ${error.message}`);
    }
    core.info(`Falling back to default environment: ${defaultEnv}`);
    return defaultEnv;
  }
}
```

## 5. Testing Strategy

### Unit Tests
- Each utility function should have comprehensive unit tests
- Use Bun's built-in test runner and assertion library
- Mock external dependencies (@actions/core, @actions/github, etc.)
- Test both success and error scenarios
- Test with different configuration options

### Integration Tests
- Use act to test the workflows with the new utilities
- Create test event files for different scenarios
- Verify that the workflows behave as expected

## 6. Workflow Updates

### Example: Updated Workflow Step
**Current:**
```yaml
- name: Set environment based on context
  id: set_env
  run: |
    if [[ "${{ github.event.inputs.environment }}" != "" ]]; then
      echo "environment=${{ github.event.inputs.environment }}" >> $GITHUB_OUTPUT
      exit 0
    fi

    if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
      echo "environment=prod" >> $GITHUB_OUTPUT
    else
      echo "environment=stg" >> $GITHUB_OUTPUT
    fi
```

**Target:**
```yaml
- name: Setup Bun
  uses: oven-sh/setup-bun@v1
  with:
    bun-version: latest

- name: Determine Environment
  id: set_env
  run: |
    output=$(bun run utils/src/terraform/environment.ts)
    echo "environment=$output" >> $GITHUB_OUTPUT
```

## 7. Documentation

### For Each Utility:
- Purpose and functionality
- Input parameters and return values
- Usage examples in workflows
- Error handling behavior
- Testing approach

## 8. Rollout Strategy

### Gradual Approach:
1. Start with low-risk utilities (environment determination, cache key generation)
2. Test thoroughly in a feature branch
3. Create a PR with the changes
4. Get team review and approval
5. Merge and monitor
6. Proceed with more complex utilities

## 9. Success Metrics

- Reduction in workflow file size and complexity
- Improved test coverage
- Faster workflow execution time
- Reduced number of workflow failures
- Positive developer feedback

## 10. Recommendation

Based on the analysis of our current workflows and the benefits of TypeScript/Bun, we recommend proceeding with this implementation plan. The initial investment in setting up the utilities will be offset by improved maintainability, testability, and reliability of our CI/CD pipelines.

The modular approach allows for gradual adoption, starting with simpler utilities and progressing to more complex ones as the team becomes comfortable with the new approach.

## 11. Next Steps

1. Create the initial directory structure and configuration files
2. Implement the first utility (environment determination)
3. Update the workflow to use the new utility
4. Test and validate the changes
5. Present the results to the team and gather feedback
6. Proceed with the next utility based on feedback