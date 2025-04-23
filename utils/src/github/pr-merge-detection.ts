/**
 * PR Merge Detection Utility
 * 
 * This script detects if a push to the main branch is from a PR merge.
 * It's used to conditionally run deployment steps only on PR merges to main.
 * 
 * Usage in workflow:
 * ```yaml
 * - name: Setup Bun
 *   uses: oven-sh/setup-bun@v1
 * 
 * - name: Check if PR merge
 *   id: check_pr_merge
 *   run: |
 *     result=$(bun run utils/src/github/pr-merge-detection.ts)
 *     echo "is_pr_merge=$result" >> $GITHUB_OUTPUT
 * ```
 */

import * as core from '@actions/core';
import * as github from '@actions/github';
import { execSync } from 'child_process';

interface PrMergeDetectionOptions {
  mainBranch?: string;
  mergeCommitPattern?: string;
}

/**
 * Detects if the current commit is a PR merge to main
 */
export function isPrMerge(options: PrMergeDetectionOptions = {}): boolean {
  const {
    mainBranch = 'main',
    mergeCommitPattern = 'Merge pull request'
  } = options;

  try {
    // First check if we're on the main branch
    const ref = github.context.ref;
    const isMergeToMain = ref === `refs/heads/${mainBranch}`;
    
    if (!isMergeToMain) {
      core.info('Not on main branch, skipping PR merge detection');
      return false;
    }
    
    // Get the commit message
    const commitMessage = getCommitMessage();
    core.info(`Commit message: ${commitMessage}`);
    
    // Check if it's a merge commit from a PR
    const isPrMergeCommit = commitMessage.startsWith(mergeCommitPattern);
    
    if (isPrMergeCommit) {
      core.info('✅ This is a PR merge commit');
      return true;
    } else {
      core.info('⚠️ This is not a PR merge commit');
      return false;
    }
  } catch (error) {
    if (error instanceof Error) {
      core.warning(`Error detecting PR merge: ${error.message}`);
    }
    return false;
  }
}

/**
 * Gets the commit message of the current commit
 */
function getCommitMessage(): string {
  try {
    // Use GitHub context if available
    if (github.context.payload.head_commit?.message) {
      return github.context.payload.head_commit.message;
    }
    
    // Fall back to git command
    return execSync('git log -1 --pretty=format:%s').toString().trim();
  } catch (error) {
    if (error instanceof Error) {
      core.warning(`Error getting commit message: ${error.message}`);
    }
    return '';
  }
}

// When run directly (not imported), execute and output the result
if (import.meta.main) {
  const result = isPrMerge();
  console.log(result.toString());
}

export default isPrMerge;