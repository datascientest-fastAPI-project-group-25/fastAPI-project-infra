import { describe, test, expect, beforeEach, afterEach } from 'bun:test';
import { determineEnvironment } from '../../src/terraform/environment';

describe('determineEnvironment', () => {
  const originalEnv = { ...process.env };

  beforeEach(() => {
    // Reset environment variables
    process.env = { ...originalEnv };
  });

  afterEach(() => {
    // Restore original environment after tests
    process.env = originalEnv;
  });

  test('should use custom environment names when provided', () => {
    // We can test the function with custom parameters without mocking
    const result = determineEnvironment({
      defaultEnv: 'dev',
      mainBranchEnv: 'production'
    });

    // Since we're not mocking github.context.ref, it will use the default
    // which should be 'dev' based on our custom parameters
    expect(result).toBe('dev');
  });

  test('should use manual input when provided', () => {
    // Mock workflow_dispatch input
    process.env.INPUT_ENVIRONMENT = 'prod';

    const result = determineEnvironment();

    // Should use the input environment regardless of branch
    expect(result).toBe('prod');
  });
});
