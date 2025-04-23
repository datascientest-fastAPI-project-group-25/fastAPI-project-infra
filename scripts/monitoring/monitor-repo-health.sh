#!/bin/bash
# monitor-repo-health.sh - Monitor GitHub Repository Health
#
# This script uses the GitHub CLI to monitor repository health, including
# branch protection rules, recent commits, and repository settings.
#
# Usage:
#   ./scripts/monitoring/monitor-repo-health.sh [options]
#
# Options:
#   -b, --branch <branch>   Check protection rules for specific branch (default: main)
#   -c, --commits <number>  Number of recent commits to display (default: 5)
#   -f, --format <format>   Output format (table, json) (default: table)
#   -h, --help              Show this help message
#
# Examples:
#   ./scripts/monitoring/monitor-repo-health.sh
#   ./scripts/monitoring/monitor-repo-health.sh --branch develop
#   ./scripts/monitoring/monitor-repo-health.sh --commits 10
#   ./scripts/monitoring/monitor-repo-health.sh --format json

set -e

# Default values
BRANCH="main"
COMMITS=5
FORMAT="table"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--branch)
      BRANCH="$2"
      shift 2
      ;;
    -c|--commits)
      COMMITS="$2"
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
      echo "  -b, --branch <branch>   Check protection rules for specific branch (default: main)"
      echo "  -c, --commits <number>  Number of recent commits to display (default: 5)"
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

# Get repository information
get_repo_info() {
  echo "Fetching repository information..."
  
  if [ "$FORMAT" = "json" ]; then
    gh api repos/:owner/:repo --jq '{
      name: .name,
      description: .description,
      default_branch: .default_branch,
      visibility: .visibility,
      created_at: .created_at,
      updated_at: .updated_at,
      pushed_at: .pushed_at,
      size: .size,
      stargazers_count: .stargazers_count,
      watchers_count: .watchers_count,
      forks_count: .forks_count,
      open_issues_count: .open_issues_count,
      license: .license.name,
      topics: .topics,
      has_issues: .has_issues,
      has_projects: .has_projects,
      has_wiki: .has_wiki,
      has_pages: .has_pages,
      has_downloads: .has_downloads,
      archived: .archived,
      disabled: .disabled,
      allow_forking: .allow_forking,
      is_template: .is_template
    }'
  else
    REPO_INFO=$(gh api repos/:owner/:repo)
    
    echo "Repository Information:"
    echo "----------------------"
    echo "Name: $(echo "$REPO_INFO" | jq -r '.name')"
    echo "Description: $(echo "$REPO_INFO" | jq -r '.description // "N/A"')"
    echo "Default Branch: $(echo "$REPO_INFO" | jq -r '.default_branch')"
    echo "Visibility: $(echo "$REPO_INFO" | jq -r '.visibility')"
    echo "Created: $(echo "$REPO_INFO" | jq -r '.created_at')"
    echo "Last Updated: $(echo "$REPO_INFO" | jq -r '.updated_at')"
    echo "Last Push: $(echo "$REPO_INFO" | jq -r '.pushed_at')"
    echo "Size: $(echo "$REPO_INFO" | jq -r '.size') KB"
    echo "Stars: $(echo "$REPO_INFO" | jq -r '.stargazers_count')"
    echo "Watchers: $(echo "$REPO_INFO" | jq -r '.watchers_count')"
    echo "Forks: $(echo "$REPO_INFO" | jq -r '.forks_count')"
    echo "Open Issues: $(echo "$REPO_INFO" | jq -r '.open_issues_count')"
    echo "License: $(echo "$REPO_INFO" | jq -r '.license.name // "N/A"')"
    echo "Topics: $(echo "$REPO_INFO" | jq -r '.topics | join(", ") // "N/A"')"
    echo ""
    echo "Features:"
    echo "  Issues: $(echo "$REPO_INFO" | jq -r '.has_issues')"
    echo "  Projects: $(echo "$REPO_INFO" | jq -r '.has_projects')"
    echo "  Wiki: $(echo "$REPO_INFO" | jq -r '.has_wiki')"
    echo "  Pages: $(echo "$REPO_INFO" | jq -r '.has_pages')"
    echo "  Downloads: $(echo "$REPO_INFO" | jq -r '.has_downloads')"
    echo "  Archived: $(echo "$REPO_INFO" | jq -r '.archived')"
    echo "  Disabled: $(echo "$REPO_INFO" | jq -r '.disabled')"
    echo "  Allow Forking: $(echo "$REPO_INFO" | jq -r '.allow_forking')"
    echo "  Is Template: $(echo "$REPO_INFO" | jq -r '.is_template')"
  fi
}

# Get branch protection rules
get_branch_protection() {
  echo "Checking branch protection rules for $BRANCH..."
  
  # Try to get branch protection rules
  PROTECTION_INFO=$(gh api repos/:owner/:repo/branches/$BRANCH/protection 2>/dev/null || echo '{"message": "Branch not protected"}')
  
  if [ "$FORMAT" = "json" ]; then
    if [[ $(echo "$PROTECTION_INFO" | jq -r '.message // ""') == "Branch not protected" ]]; then
      echo '{"protected": false}'
    else
      echo "$PROTECTION_INFO"
    fi
  else
    if [[ $(echo "$PROTECTION_INFO" | jq -r '.message // ""') == "Branch not protected" ]]; then
      echo "Branch Protection Status for '$BRANCH':"
      echo "------------------------------------"
      echo "⚠️  WARNING: Branch is not protected!"
      echo ""
      echo "Consider enabling branch protection with:"
      echo "- Required pull request reviews"
      echo "- Required status checks"
      echo "- Restrictions on who can push"
    else
      echo "Branch Protection Status for '$BRANCH':"
      echo "------------------------------------"
      echo "✅ Branch is protected"
      echo ""
      
      # Required status checks
      if [[ $(echo "$PROTECTION_INFO" | jq -r '.required_status_checks != null') == "true" ]]; then
        echo "Required Status Checks:"
        echo "  Strict: $(echo "$PROTECTION_INFO" | jq -r '.required_status_checks.strict')"
        echo "  Contexts: $(echo "$PROTECTION_INFO" | jq -r '.required_status_checks.contexts | join(", ") // "None"')"
      else
        echo "Required Status Checks: Not enabled"
      fi
      
      # Required pull request reviews
      if [[ $(echo "$PROTECTION_INFO" | jq -r '.required_pull_request_reviews != null') == "true" ]]; then
        echo "Required Pull Request Reviews:"
        echo "  Dismiss stale reviews: $(echo "$PROTECTION_INFO" | jq -r '.required_pull_request_reviews.dismiss_stale_reviews')"
        echo "  Required approving review count: $(echo "$PROTECTION_INFO" | jq -r '.required_pull_request_reviews.required_approving_review_count // "None"')"
      else
        echo "Required Pull Request Reviews: Not enabled"
      fi
      
      # Enforce admins
      echo "Enforce Admins: $(echo "$PROTECTION_INFO" | jq -r '.enforce_admins.enabled')"
      
      # Restrictions
      if [[ $(echo "$PROTECTION_INFO" | jq -r '.restrictions != null') == "true" ]]; then
        echo "Restrictions: Enabled"
        echo "  Users: $(echo "$PROTECTION_INFO" | jq -r '.restrictions.users | length')"
        echo "  Teams: $(echo "$PROTECTION_INFO" | jq -r '.restrictions.teams | length')"
        echo "  Apps: $(echo "$PROTECTION_INFO" | jq -r '.restrictions.apps | length')"
      else
        echo "Restrictions: Not enabled"
      fi
    fi
  fi
}

# Get recent commits
get_recent_commits() {
  echo "Fetching recent commits..."
  
  if [ "$FORMAT" = "json" ]; then
    gh api repos/:owner/:repo/commits?per_page=$COMMITS --jq '[.[] | {
      sha: .sha,
      author: .commit.author.name,
      email: .commit.author.email,
      date: .commit.author.date,
      message: .commit.message,
      url: .html_url
    }]'
  else
    COMMITS_INFO=$(gh api repos/:owner/:repo/commits?per_page=$COMMITS)
    
    echo "Recent Commits:"
    echo "--------------"
    echo "SHA | AUTHOR | DATE | MESSAGE | URL"
    echo "--- | ------ | ---- | ------- | ---"
    
    echo "$COMMITS_INFO" | jq -r '.[] | "\(.sha[0:7]) | \(.commit.author.name) | \(.commit.author.date) | \(.commit.message | split("\n")[0]) | \(.html_url)"'
  fi
}

# Get workflows
get_workflows() {
  echo "Fetching workflows..."
  
  if [ "$FORMAT" = "json" ]; then
    gh api repos/:owner/:repo/actions/workflows --jq '.workflows | map({
      id: .id,
      name: .name,
      path: .path,
      state: .state,
      created_at: .created_at,
      updated_at: .updated_at,
      url: .html_url
    })'
  else
    WORKFLOWS_INFO=$(gh api repos/:owner/:repo/actions/workflows)
    
    echo "GitHub Actions Workflows:"
    echo "------------------------"
    echo "ID | NAME | PATH | STATE | CREATED | UPDATED | URL"
    echo "-- | ---- | ---- | ----- | ------- | ------- | ---"
    
    echo "$WORKFLOWS_INFO" | jq -r '.workflows[] | "\(.id) | \(.name) | \(.path) | \(.state) | \(.created_at) | \(.updated_at) | \(.html_url)"'
  fi
}

# Run all checks
if [ "$FORMAT" = "json" ]; then
  echo "{"
  echo "  \"repository\": "
  get_repo_info
  echo ","
  echo "  \"branch_protection\": "
  get_branch_protection
  echo ","
  echo "  \"recent_commits\": "
  get_recent_commits
  echo ","
  echo "  \"workflows\": "
  get_workflows
  echo "}"
else
  get_repo_info
  echo ""
  get_branch_protection
  echo ""
  get_recent_commits
  echo ""
  get_workflows
fi