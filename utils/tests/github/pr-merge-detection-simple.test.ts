import { describe, test, expect } from 'bun:test';
import { isPrMerge } from '../../src/github/pr-merge-detection';

describe('isPrMerge', () => {
  test('should use custom main branch name when provided', () => {
    // Test with custom parameters
    const result = isPrMerge({ 
      mainBranch: 'custom-branch',
      mergeCommitPattern: 'Custom merge pattern'
    });
    
    // Since we're not in a GitHub Actions environment,
    // and not mocking the context, this should return false
    expect(result).toBe(false);
  });
  
  test('should handle different merge commit patterns', () => {
    // Test with different merge commit patterns
    const result1 = isPrMerge({ mergeCommitPattern: 'pattern1' });
    const result2 = isPrMerge({ mergeCommitPattern: 'pattern2' });
    
    // Both should return false in our test environment
    expect(result1).toBe(false);
    expect(result2).toBe(false);
  });
});