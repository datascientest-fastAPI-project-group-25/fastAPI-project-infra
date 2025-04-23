import { describe, test, expect } from 'bun:test';

describe('simple test', () => {
  test('should pass', () => {
    expect(1 + 1).toBe(2);
  });
});