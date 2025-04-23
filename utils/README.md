# Helper Utils for GitHub Actions Workflows

This directory contains helper utilities for GitHub Actions workflows, implemented using Bun and TypeScript.

## Benefits of Using Bun/TypeScript for Workflow Scripts

1. **Type Safety**: TypeScript provides static typing, which helps catch errors at compile time rather than runtime.
2. **Better Code Organization**: Modular code structure with proper imports/exports.
3. **Improved Maintainability**: Easier to understand, test, and refactor than complex Bash scripts.
4. **Modern JavaScript Features**: Access to modern JS features and libraries.
5. **Fast Execution**: Bun is significantly faster than Node.js for script execution.
6. **Built-in Testing**: Bun has built-in test runners and assertion libraries.
7. **Simplified JSON Handling**: Native JSON parsing and manipulation.
8. **Cross-Platform Compatibility**: Works consistently across different operating systems.

## Directory Structure

```
utils/
├── README.md
├── package.json
├── tsconfig.json
├── src/
│   ├── terraform/
│   │   ├── environment.ts
│   │   ├── caching.ts
│   │   ├── planning.ts
│   │   └── deployment.ts
│   ├── github/
│   │   ├── pr.ts
│   │   ├── branch.ts
│   │   └── comments.ts
│   ├── aws/
│   │   ├── auth.ts
│   │   └── resources.ts
│   └── common/
│       ├── logging.ts
│       └── config.ts
└── tests/
    ├── terraform/
    ├── github/
    ├── aws/
    └── common/
```

## Usage in Workflows

To use these utilities in GitHub Actions workflows:

1. Install Bun in your workflow:
   ```yaml
   - name: Setup Bun
     uses: oven-sh/setup-bun@v1
     with:
       bun-version: latest
   ```

2. Call the utility scripts:
   ```yaml
   - name: Determine Environment
     id: env
     run: |
       output=$(bun run utils/src/terraform/environment.ts)
       echo "environment=$output" >> $GITHUB_OUTPUT
   ```

## Testing

Run tests using Bun's built-in test runner:

```bash
bun test
```

## Development

1. Install dependencies:
   ```bash
   bun install
   ```

2. Build the project:
   ```bash
   bun run build
   ```

3. Run a specific utility:
   ```bash
   bun run src/terraform/environment.ts
   ```