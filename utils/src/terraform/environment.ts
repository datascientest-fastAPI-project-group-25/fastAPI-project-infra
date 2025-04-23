/**
 * Environment Determination Utility
 * 
 * This script determines the deployment environment (stg/prod) based on:
 * 1. Manual input from workflow_dispatch
 * 2. Branch context (main = prod, others = stg)
 * 
 * Usage in workflow:
 * ```yaml
 * - name: Setup Bun
 *   uses: oven-sh/setup-bun@v1
 * 
 * - name: Determine Environment
 *   id: set_env
 *   run: |
 *     output=$(bun run utils/src/terraform/environment.ts)
 *     echo "environment=$output" >> $GITHUB_OUTPUT
 * ```
 */

import * as core from '@actions/core';
import * as github from '@actions/github';

interface EnvironmentOptions {
  defaultEnv?: string;
  mainBranchEnv?: string;
  inputEnvName?: string;
}

/**
 * Determines the deployment environment based on context
 */
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

// When run directly (not imported), execute and output the result
if (import.meta.main) {
  const environment = determineEnvironment();
  console.log(environment);
}

export default determineEnvironment;