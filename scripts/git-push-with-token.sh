#!/bin/bash

# Script to push changes using a GitHub personal access token
# Usage: ./scripts/git-push-with-token.sh YOUR_GITHUB_TOKEN

if [ $# -ne 1 ]; then
  echo "Usage: $0 YOUR_GITHUB_TOKEN"
  exit 1
fi

TOKEN=$1
BRANCH=$(git symbolic-ref --short HEAD)
REPO_URL=$(git remote get-url origin)
REPO_URL_WITH_TOKEN=$(echo $REPO_URL | sed -E "s|https://|https://x-access-token:$TOKEN@|")

echo "Pushing to branch: $BRANCH"
git push $REPO_URL_WITH_TOKEN $BRANCH
