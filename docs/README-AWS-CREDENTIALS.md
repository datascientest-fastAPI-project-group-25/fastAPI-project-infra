# AWS Credentials Setup for GitHub Actions

This document explains how to set up AWS credentials as GitHub secrets for use in GitHub Actions workflows.

## AWS Credentials

The following AWS credentials are required for the GitHub Actions workflows to work properly:

- **AWS Account ID**: Your AWS account ID
- **Access Key**: Your AWS access key
- **Secret Key**: Your AWS secret key

These credentials should be stored as GitHub secrets and never committed to the repository.

## Setting Up GitHub Secrets

To set up the AWS credentials as GitHub secrets, follow these steps:

1. Go to your GitHub repository.
2. Click on "Settings" in the top navigation bar.
3. In the left sidebar, click on "Secrets and variables" and then "Actions".
4. Click on "New repository secret" to add a new secret.
5. Add the following secrets:
   - Name: `AWS_ACCOUNT_ID`, Value: Your AWS account ID
   - Name: `AWS_ACCESS_KEY` or `AWS_ACCESS_KEY_ID`, Value: Your AWS access key
   - Name: `AWS_SECRET_KEY` or `AWS_SECRET_ACCESS_KEY`, Value: Your AWS secret key

   Note: The GitHub Actions workflow in this repository uses `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, so make sure to use these names or update the workflow to match your secret names.

## Verifying GitHub Secrets

To verify that the GitHub secrets are set up correctly, you can use the GitHub CLI:

```bash
gh secret list
```

This should show the following secrets:
- `AWS_ACCOUNT_ID`
- `AWS_ACCESS_KEY` or `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_KEY` or `AWS_SECRET_ACCESS_KEY`

## Using AWS Credentials in GitHub Actions

The GitHub Actions workflow is already configured to use these secrets. The workflow uses the following environment variables:

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
  AWS_DEFAULT_REGION: eu-west-2
```

These environment variables are used by the AWS CLI and Terraform to authenticate with AWS.

Note: If you've set up your secrets with different names (e.g., `AWS_ACCESS_KEY` instead of `AWS_ACCESS_KEY_ID`), you'll need to update the workflow file to match your secret names.

## Security Considerations

- **Never commit AWS credentials directly to your repository.** Always use GitHub secrets or other secure methods to store and access credentials.
- Consider using IAM roles with limited permissions for GitHub Actions workflows.
- Regularly rotate your AWS access keys to minimize the risk of unauthorized access.
- Monitor your AWS account for unusual activity.

## Troubleshooting

If you encounter issues with AWS authentication in GitHub Actions, check the following:

1. Verify that the GitHub secrets are set up correctly.
2. Check that the AWS credentials are valid and have the necessary permissions.
3. Ensure that the AWS region is set correctly in the workflow.
4. Look for error messages in the GitHub Actions logs.

For more information, see the [GitHub Actions documentation](https://docs.github.com/en/actions) and the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).
