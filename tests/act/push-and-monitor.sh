#!/bin/bash
# Script to push changes to GitHub and monitor workflow execution

# Ensure we're in the repository root
cd "$(git rev-parse --show-toplevel)" || exit 1

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first:"
    echo "  brew install gh  # macOS"
    echo "  https://github.com/cli/cli#installation  # Other platforms"
    exit 1
fi

# Check if user is authenticated with gh
if ! gh auth status &> /dev/null; then
    echo "Please authenticate with GitHub CLI first:"
    echo "  gh auth login"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Check if there are any changes to commit
if [[ -z $(git status --porcelain) ]]; then
    echo "No changes to commit."
    exit 0
fi

# Commit changes
echo "Committing changes..."
git add .
git commit -m "Update Terraform workflow to only deploy on PR merge to main"

# Push changes
echo "Pushing changes to GitHub..."
git push origin "$CURRENT_BRANCH"

# Check if a PR already exists
PR_EXISTS=$(gh pr list --head "$CURRENT_BRANCH" --json number --jq 'length')

if [[ "$PR_EXISTS" -eq 0 ]]; then
    # Create PR
    echo "Creating PR..."
    PR_URL=$(gh pr create --title "Update Terraform workflow to only deploy on PR merge" \
                         --body "This PR updates the Terraform workflow to only run deployment on merge of PR to main. Authentication and prerequisite checks happen during PR validation." \
                         --base main)
    echo "PR created: $PR_URL"
else
    echo "PR already exists for branch $CURRENT_BRANCH"
    PR_URL=$(gh pr view --json url --jq '.url')
    echo "PR URL: $PR_URL"
fi

# Monitor workflow execution
echo "Monitoring workflow execution..."
gh run watch

echo "Done! You can check the workflow status on GitHub."