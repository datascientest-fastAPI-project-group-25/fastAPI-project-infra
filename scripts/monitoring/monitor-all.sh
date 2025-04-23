#!/bin/bash
# monitor-all.sh - Run all GitHub monitoring scripts
#
# This script runs all the GitHub monitoring scripts in sequence,
# providing a comprehensive overview of the repository status.
#
# Usage:
#   ./scripts/monitoring/monitor-all.sh [options]
#
# Options:
#   -f, --format <format>   Output format (table, json) (default: table)
#   -h, --help              Show this help message
#
# Examples:
#   ./scripts/monitoring/monitor-all.sh
#   ./scripts/monitoring/monitor-all.sh --format json

set -e

# Default values
FORMAT="table"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--format)
      FORMAT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -f, --format <format>   Output format (table, json) (default: table)"
      echo "  -h, --help              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is not installed."
  echo "Please install it from https://cli.github.com/"
  exit 1
fi

# Check if user is authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
  echo "Error: You are not authenticated with GitHub CLI."
  echo "Please run 'gh auth login' to authenticate."
  exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print header
if [ "$FORMAT" = "table" ]; then
  echo "==============================================="
  echo "🔍 GitHub Repository Monitoring Report"
  echo "==============================================="
  echo "Generated: $(date)"
  echo "Repository: $(gh repo view --json nameWithOwner -q .nameWithOwner)"
  echo "==============================================="
  echo ""
fi

# Run repository health check
if [ "$FORMAT" = "table" ]; then
  echo "==============================================="
  echo "📊 REPOSITORY HEALTH"
  echo "==============================================="
  "$SCRIPT_DIR/monitor-repo-health.sh" --format "$FORMAT"
  echo ""
else
  "$SCRIPT_DIR/monitor-repo-health.sh" --format "$FORMAT"
fi

# Run workflow monitoring
if [ "$FORMAT" = "table" ]; then
  echo "==============================================="
  echo "⚙️ WORKFLOW STATUS"
  echo "==============================================="
  "$SCRIPT_DIR/monitor-workflows.sh" --format "$FORMAT"
  echo ""
else
  "$SCRIPT_DIR/monitor-workflows.sh" --format "$FORMAT"
fi

# Run issues and PRs monitoring
if [ "$FORMAT" = "table" ]; then
  echo "==============================================="
  echo "🔖 ISSUES AND PULL REQUESTS"
  echo "==============================================="
  "$SCRIPT_DIR/monitor-issues-prs.sh" --format "$FORMAT"
  echo ""
else
  "$SCRIPT_DIR/monitor-issues-prs.sh" --format "$FORMAT"
fi

# Print footer
if [ "$FORMAT" = "table" ]; then
  echo "==============================================="
  echo "End of monitoring report"
  echo "==============================================="
fi