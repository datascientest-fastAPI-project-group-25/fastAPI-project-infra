#!/bin/bash
# monitor-workflows.sh - Monitor GitHub Actions workflow runs
#
# This script uses the GitHub CLI to monitor workflow runs in the repository.
# It provides options to filter by workflow name, branch, and status.
#
# Usage:
#   ./scripts/monitoring/monitor-workflows.sh [options]
#
# Options:
#   -w, --workflow <name>   Filter by workflow name
#   -b, --branch <branch>   Filter by branch name
#   -s, --status <status>   Filter by status (success, failure, cancelled, skipped, in_progress)
#   -l, --limit <number>    Limit the number of runs to display (default: 10)
#   -f, --format <format>   Output format (table, json) (default: table)
#   -a, --all               Show all workflow runs (default: show only the latest run per workflow)
#   -h, --help              Show this help message
#
# Examples:
#   ./scripts/monitoring/monitor-workflows.sh
#   ./scripts/monitoring/monitor-workflows.sh --workflow "Terraform Infrastructure Deployment"
#   ./scripts/monitoring/monitor-workflows.sh --branch main --status failure
#   ./scripts/monitoring/monitor-workflows.sh --all --limit 20
#   ./scripts/monitoring/monitor-workflows.sh --format json

set -e

# Default values
WORKFLOW=""
BRANCH=""
STATUS=""
LIMIT=10
FORMAT="table"
SHOW_ALL=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--workflow)
      WORKFLOW="$2"
      shift 2
      ;;
    -b|--branch)
      BRANCH="$2"
      shift 2
      ;;
    -s|--status)
      STATUS="$2"
      shift 2
      ;;
    -l|--limit)
      LIMIT="$2"
      shift 2
      ;;
    -f|--format)
      FORMAT="$2"
      shift 2
      ;;
    -a|--all)
      SHOW_ALL=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -w, --workflow <name>   Filter by workflow name"
      echo "  -b, --branch <branch>   Filter by branch name"
      echo "  -s, --status <status>   Filter by status (success, failure, cancelled, skipped, in_progress)"
      echo "  -l, --limit <number>    Limit the number of runs to display (default: 10)"
      echo "  -f, --format <format>   Output format (table, json) (default: table)"
      echo "  -a, --all               Show all workflow runs (default: show only the latest run per workflow)"
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

# Build the query parameters
QUERY_PARAMS=""

if [ -n "$WORKFLOW" ]; then
  QUERY_PARAMS="$QUERY_PARAMS --workflow \"$WORKFLOW\""
fi

if [ -n "$BRANCH" ]; then
  QUERY_PARAMS="$QUERY_PARAMS --branch \"$BRANCH\""
fi

if [ -n "$STATUS" ]; then
  QUERY_PARAMS="$QUERY_PARAMS --status \"$STATUS\""
fi

QUERY_PARAMS="$QUERY_PARAMS --limit $LIMIT"

# Define the fields to include in the output
if [ "$FORMAT" = "table" ]; then
  FIELDS="name,displayTitle,headBranch,status,conclusion,createdAt,updatedAt,url"
else
  FIELDS="name,displayTitle,headBranch,status,conclusion,createdAt,updatedAt,url,databaseId"
fi

# Get the workflow runs
echo "Fetching workflow runs..."
if [ "$SHOW_ALL" = true ]; then
  # Show all workflow runs
  eval "gh run list $QUERY_PARAMS --json $FIELDS"
else
  # Show only the latest run per workflow
  WORKFLOWS=$(gh workflow list --json name -q '.[].name')
  
  if [ "$FORMAT" = "json" ]; then
    echo "["
    FIRST=true
    
    for WF in $WORKFLOWS; do
      if [ "$FIRST" = true ]; then
        FIRST=false
      else
        echo ","
      fi
      
      LATEST_RUN=$(eval "gh run list --workflow \"$WF\" $QUERY_PARAMS --limit 1 --json $FIELDS -q '.[0]'")
      if [ -n "$LATEST_RUN" ]; then
        echo "$LATEST_RUN"
      fi
    done
    
    echo "]"
  else
    # Table format
    echo "Latest workflow runs:"
    echo ""
    echo "WORKFLOW | TITLE | BRANCH | STATUS | CONCLUSION | CREATED | UPDATED | URL"
    echo "-------- | ----- | ------ | ------ | ---------- | ------- | ------- | ---"
    
    for WF in $WORKFLOWS; do
      LATEST_RUN=$(eval "gh run list --workflow \"$WF\" $QUERY_PARAMS --limit 1 --json $FIELDS")
      if [ -n "$LATEST_RUN" ]; then
        echo "$LATEST_RUN" | jq -r '.[0] | "\(.name) | \(.displayTitle) | \(.headBranch) | \(.status) | \(.conclusion) | \(.createdAt) | \(.updatedAt) | \(.url)"'
      fi
    done
  fi
fi

# Print a summary of workflow statuses
if [ "$FORMAT" = "table" ]; then
  echo ""
  echo "Summary:"
  echo "--------"
  
  # Count workflows by status
  SUCCESS_COUNT=$(gh run list --limit 100 --json conclusion -q '[.[] | select(.conclusion == "success")] | length')
  FAILURE_COUNT=$(gh run list --limit 100 --json conclusion -q '[.[] | select(.conclusion == "failure")] | length')
  CANCELLED_COUNT=$(gh run list --limit 100 --json conclusion -q '[.[] | select(.conclusion == "cancelled")] | length')
  IN_PROGRESS_COUNT=$(gh run list --limit 100 --json status -q '[.[] | select(.status == "in_progress")] | length')
  
  echo "Success: $SUCCESS_COUNT"
  echo "Failure: $FAILURE_COUNT"
  echo "Cancelled: $CANCELLED_COUNT"
  echo "In Progress: $IN_PROGRESS_COUNT"
fi