# GitHub Monitoring Scripts

This directory contains scripts for monitoring various aspects of the GitHub repository using the GitHub CLI (`gh`).

## Prerequisites

- [GitHub CLI](https://cli.github.com/) installed and authenticated
- `jq` command-line JSON processor
- Bash shell

## Installation

1. Make sure you have the GitHub CLI installed:
   ```bash
   # Install GitHub CLI
   # macOS
   brew install gh

   # Ubuntu/Debian
   sudo apt install gh

   # Fedora
   sudo dnf install gh
   ```

2. Authenticate with GitHub:
   ```bash
   gh auth login
   ```

3. Make the scripts executable:
   ```bash
   chmod +x scripts/monitoring/*.sh
   ```

## Available Scripts

### 1. Combined Monitoring (`monitor-all.sh`)

Run all monitoring scripts at once for a comprehensive overview of the repository status.

```bash
./scripts/monitoring/monitor-all.sh [options]
```

**Options:**
- `-f, --format <format>`: Output format (table, json) (default: table)
- `-h, --help`: Show help message

**Examples:**
```bash
# Run all monitoring checks with default settings
./scripts/monitoring/monitor-all.sh

# Output all monitoring checks in JSON format
./scripts/monitoring/monitor-all.sh --format json
```

### 2. Monitor Workflows (`monitor-workflows.sh`)

Monitor GitHub Actions workflow runs in the repository.

```bash
./scripts/monitoring/monitor-workflows.sh [options]
```

**Options:**
- `-w, --workflow <name>`: Filter by workflow name
- `-b, --branch <branch>`: Filter by branch name
- `-s, --status <status>`: Filter by status (success, failure, cancelled, skipped, in_progress)
- `-l, --limit <number>`: Limit the number of runs to display (default: 10)
- `-f, --format <format>`: Output format (table, json) (default: table)
- `-a, --all`: Show all workflow runs (default: show only the latest run per workflow)
- `-h, --help`: Show help message

**Examples:**
```bash
# Show latest run of each workflow
./scripts/monitoring/monitor-workflows.sh

# Show runs for a specific workflow
./scripts/monitoring/monitor-workflows.sh --workflow "Terraform Infrastructure Deployment"

# Show failed runs on the main branch
./scripts/monitoring/monitor-workflows.sh --branch main --status failure

# Show all recent workflow runs
./scripts/monitoring/monitor-workflows.sh --all --limit 20

# Output in JSON format
./scripts/monitoring/monitor-workflows.sh --format json
```

### 2. Monitor Issues and PRs (`monitor-issues-prs.sh`)

Monitor issues and pull requests in the repository.

```bash
./scripts/monitoring/monitor-issues-prs.sh [options]
```

**Options:**
- `-t, --type <type>`: Filter by type (issues, prs, both) (default: both)
- `-l, --label <label>`: Filter by label (can be used multiple times)
- `-a, --assignee <user>`: Filter by assignee (can be used multiple times)
- `-s, --state <state>`: Filter by state (open, closed, all) (default: open)
- `-n, --limit <number>`: Limit the number of items to display (default: 10)
- `-f, --format <format>`: Output format (table, json) (default: table)
- `-h, --help`: Show help message

**Examples:**
```bash
# Show open issues and PRs
./scripts/monitoring/monitor-issues-prs.sh

# Show only issues
./scripts/monitoring/monitor-issues-prs.sh --type issues

# Show PRs with the 'bug' label
./scripts/monitoring/monitor-issues-prs.sh --type prs --label bug

# Show all items assigned to a specific user
./scripts/monitoring/monitor-issues-prs.sh --assignee username --state all

# Output in JSON format
./scripts/monitoring/monitor-issues-prs.sh --format json
```

### 3. Monitor Repository Health (`monitor-repo-health.sh`)

Monitor repository health, including branch protection rules, recent commits, and repository settings.

```bash
./scripts/monitoring/monitor-repo-health.sh [options]
```

**Options:**
- `-b, --branch <branch>`: Check protection rules for specific branch (default: main)
- `-c, --commits <number>`: Number of recent commits to display (default: 5)
- `-f, --format <format>`: Output format (table, json) (default: table)
- `-h, --help`: Show help message

**Examples:**
```bash
# Check repository health with default settings
./scripts/monitoring/monitor-repo-health.sh

# Check protection rules for a different branch
./scripts/monitoring/monitor-repo-health.sh --branch develop

# Show more recent commits
./scripts/monitoring/monitor-repo-health.sh --commits 10

# Output in JSON format
./scripts/monitoring/monitor-repo-health.sh --format json
```

## Integration with CI/CD

These scripts can be integrated into CI/CD pipelines to automate monitoring. For example:

```yaml
name: Repository Health Check

on:
  schedule:
    - cron: '0 9 * * 1-5'  # Run at 9 AM Monday-Friday
  workflow_dispatch:  # Allow manual triggering

jobs:
  health-check:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install GitHub CLI
        run: |
          sudo apt-get update
          sudo apt-get install -y gh jq

      - name: Setup GitHub CLI
        run: |
          echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token

      # Option 1: Run all monitoring checks at once
      - name: Run all monitoring checks
        run: |
          ./scripts/monitoring/monitor-all.sh

      # Option 2: Run specific monitoring checks
      # - name: Run health check
      #   run: |
      #     ./scripts/monitoring/monitor-repo-health.sh
      #     
      # - name: Check workflow status
      #   run: |
      #     ./scripts/monitoring/monitor-workflows.sh --status failure
      #     
      # - name: Check stale PRs
      #   run: |
      #     ./scripts/monitoring/monitor-issues-prs.sh --type prs
```

## Troubleshooting

If you encounter issues with the scripts:

1. Ensure GitHub CLI is properly installed and authenticated:
   ```bash
   gh --version
   gh auth status
   ```

2. Check that you have the necessary permissions for the repository.

3. For API rate limit issues, consider using a personal access token with higher rate limits:
   ```bash
   gh auth login --with-token < my_token.txt
   ```

## Contributing

Feel free to enhance these scripts or add new monitoring capabilities. Please follow these guidelines:
- Maintain consistent option naming across scripts
- Include comprehensive help documentation
- Support both human-readable and machine-readable (JSON) output
- Add examples to this README for any new functionality
