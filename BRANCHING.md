# Git Branching Strategy

This document outlines the Git branching strategy for the fastAPI-project-infra repository.

## Branch Structure

The repository follows a simplified trunk-based development model:

- `main`: The production branch. All code in this branch should be stable and deployable.
- `feat/*`: Feature branches for new features or enhancements.
- `fix/*`: Fix branches for bug fixes.

## Environment Structure

Instead of using separate branches for different environments, we use folder-based environments:

- `environments/stg/`: Configuration for the staging environment.
- `environments/prod/`: Configuration for the production environment.

## Workflow

### Creating a New Feature Branch

To create a new feature branch:

```bash
make git_feature
```

You will be prompted to enter a feature name. Use hyphens instead of spaces (e.g., `new-security-module`).

### Creating a New Fix Branch

To create a new fix branch:

```bash
make git_fix
```

You will be prompted to enter a fix name. Use hyphens instead of spaces (e.g., `broken-terraform-module`).

### Committing Changes in Logical Groups

To commit changes in logical groups:

```bash
make git_commit
```

This will:
1. Show you all available files to commit
2. Prompt you to enter the files you want to commit (space-separated, or `.` for all)
3. Show you the files staged for commit
4. Prompt you to enter a commit message

### Pushing Your Branch

To push your branch to the remote repository:

```bash
make git_push
```

### Merging to Main Branch

When your feature or fix is complete, merge it to the main branch:

```bash
make git_merge_main
```

This will:
1. Checkout the main branch
2. Merge your current branch into main
3. Push the main branch to the remote repository
4. Return to your original branch

### Checking Status

To check the status of your Git repository:

```bash
make git_status
```

## Best Practices

1. **Keep branches focused**: Each branch should address a single feature or fix.
2. **Commit in logical groups**: Use `make git_commit` to commit related changes together.
3. **Write descriptive commit messages**: Clearly explain what changes were made and why.
4. **Regularly pull from main**: Keep your feature or fix branch up to date with the latest changes in main.
5. **Delete branches after merging**: Clean up branches that have been merged to keep the repository tidy.

## Branch Protection

The `main` branch is protected and requires pull requests to be reviewed before merging. Direct pushes to `main` are not allowed.

Feature branches should be thoroughly tested before creating a pull request to merge into `main`.
