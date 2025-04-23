#!/bin/bash
# monitor-issues-prs.sh - Monitor GitHub Issues and Pull Requests
#
# This script uses the GitHub CLI to monitor issues and pull requests in the repository.
# It provides options to filter by labels, assignees, and status.
#
# Usage:
#   ./scripts/monitoring/monitor-issues-prs.sh [options]
#
# Options:
#   -t, --type <type>       Filter by type (issues, prs, both) (default: both)
#   -l, --label <label>     Filter by label (can be used multiple times)
#   -a, --assignee <user>   Filter by assignee (can be used multiple times)
#   -s, --state <state>     Filter by state (open, closed, all) (default: open)
#   -n, --limit <number>    Limit the number of items to display (default: 10)
#   -f, --format <format>   Output format (table, json) (default: table)
#   -h, --help              Show this help message
#
# Examples:
#   ./scripts/monitoring/monitor-issues-prs.sh
#   ./scripts/monitoring/monitor-issues-prs.sh --type issues
#   ./scripts/monitoring/monitor-issues-prs.sh --type prs --label bug
#   ./scripts/monitoring/monitor-issues-prs.sh --assignee username --state all
#   ./scripts/monitoring/monitor-issues-prs.sh --format json

set -e

# Default values
TYPE="both"
LABELS=()
ASSIGNEES=()
STATE="open"
LIMIT=10
FORMAT="table"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--type)
      TYPE="$2"
      shift 2
      ;;
    -l|--label)
      LABELS+=("$2")
      shift 2
      ;;
    -a|--assignee)
      ASSIGNEES+=("$2")
      shift 2
      ;;
    -s|--state)
      STATE="$2"
      shift 2
      ;;
    -n|--limit)
      LIMIT="$2"
      shift 2
      ;;
    -f|--format)
      FORMAT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -t, --type <type>       Filter by type (issues, prs, both) (default: both)"
      echo "  -l, --label <label>     Filter by label (can be used multiple times)"
      echo "  -a, --assignee <user>   Filter by assignee (can be used multiple times)"
      echo "  -s, --state <state>     Filter by state (open, closed, all) (default: open)"
      echo "  -n, --limit <number>    Limit the number of items to display (default: 10)"
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

# Build the query parameters for issues
ISSUE_QUERY_PARAMS="--state $STATE --limit $LIMIT"

for LABEL in "${LABELS[@]}"; do
  ISSUE_QUERY_PARAMS="$ISSUE_QUERY_PARAMS --label \"$LABEL\""
done

for ASSIGNEE in "${ASSIGNEES[@]}"; do
  ISSUE_QUERY_PARAMS="$ISSUE_QUERY_PARAMS --assignee \"$ASSIGNEE\""
done

# Define the fields to include in the output
FIELDS="number,title,state,createdAt,updatedAt,labels,assignees,url"

# Function to display issues
display_issues() {
  echo "Fetching issues..."
  
  if [ "$FORMAT" = "json" ]; then
    eval "gh issue list $ISSUE_QUERY_PARAMS --json $FIELDS"
  else
    echo "Issues:"
    echo ""
    echo "NUMBER | TITLE | STATE | CREATED | UPDATED | LABELS | ASSIGNEES | URL"
    echo "------ | ----- | ----- | ------- | ------- | ------ | --------- | ---"
    
    ISSUES=$(eval "gh issue list $ISSUE_QUERY_PARAMS --json $FIELDS")
    if [ -n "$ISSUES" ]; then
      echo "$ISSUES" | jq -r '.[] | "\(.number) | \(.title) | \(.state) | \(.createdAt) | \(.updatedAt) | \(.labels | map(.name) | join(",")) | \(.assignees | map(.login) | join(",")) | \(.url)"'
    fi
  fi
}

# Function to display pull requests
display_prs() {
  echo "Fetching pull requests..."
  
  if [ "$FORMAT" = "json" ]; then
    eval "gh pr list $ISSUE_QUERY_PARAMS --json $FIELDS,baseRefName,headRefName,isDraft,mergeable"
  else
    echo "Pull Requests:"
    echo ""
    echo "NUMBER | TITLE | STATE | CREATED | UPDATED | LABELS | ASSIGNEES | BASE | HEAD | DRAFT | MERGEABLE | URL"
    echo "------ | ----- | ----- | ------- | ------- | ------ | --------- | ---- | ---- | ----- | --------- | ---"
    
    PRS=$(eval "gh pr list $ISSUE_QUERY_PARAMS --json $FIELDS,baseRefName,headRefName,isDraft,mergeable")
    if [ -n "$PRS" ]; then
      echo "$PRS" | jq -r '.[] | "\(.number) | \(.title) | \(.state) | \(.createdAt) | \(.updatedAt) | \(.labels | map(.name) | join(",")) | \(.assignees | map(.login) | join(",")) | \(.baseRefName) | \(.headRefName) | \(.isDraft) | \(.mergeable) | \(.url)"'
    fi
  fi
}

# Display issues and/or pull requests based on the type
if [ "$TYPE" = "issues" ] || [ "$TYPE" = "both" ]; then
  display_issues
  
  if [ "$TYPE" = "both" ] && [ "$FORMAT" = "table" ]; then
    echo ""
    echo ""
  fi
fi

if [ "$TYPE" = "prs" ] || [ "$TYPE" = "both" ]; then
  display_prs
fi

# Print a summary if using table format
if [ "$FORMAT" = "table" ]; then
  echo ""
  echo "Summary:"
  echo "--------"
  
  # Count open issues
  OPEN_ISSUES=$(gh issue list --state open --json number -q 'length')
  echo "Open Issues: $OPEN_ISSUES"
  
  # Count open PRs
  OPEN_PRS=$(gh pr list --state open --json number -q 'length')
  echo "Open Pull Requests: $OPEN_PRS"
  
  # Count PRs ready for review
  READY_PRS=$(gh pr list --state open --json isDraft -q '[.[] | select(.isDraft == false)] | length')
  echo "PRs Ready for Review: $READY_PRS"
  
  # Count draft PRs
  DRAFT_PRS=$(gh pr list --state open --json isDraft -q '[.[] | select(.isDraft == true)] | length')
  echo "Draft PRs: $DRAFT_PRS"
  
  # Count mergeable PRs
  MERGEABLE_PRS=$(gh pr list --state open --json mergeable -q '[.[] | select(.mergeable == "MERGEABLE")] | length')
  echo "Mergeable PRs: $MERGEABLE_PRS"
fi