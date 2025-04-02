- [x] get code from GPT into Codebase
- [x] adapt to reality and our gh / aws
  - [x] Modified Terraform configuration to work with SCP restrictions
  - [x] Updated IAM configuration to use existing OIDC provider
  - [x] Created IAM policy with necessary permissions
  - [x] Fixed GitHub Actions workflow for local testing
- [ ] run and make work
  - [x] Successfully initialized Terraform
  - [x] Verified configuration with terraform plan
  - [ ] Test GitHub Actions workflow locally using act
  - [ ] Push changes to GitHub
  - [ ] Test GitHub Actions workflow in GitHub
- [ ] add tests etc. PRECOMMIT
  - [ ] Add pre-commit hooks for Terraform validation
  - [ ] Add Checkov security scanning
- [ ] add tests etc. GH ACTION
  - [ ] Add Terraform validation in GitHub Actions
  - [ ] Add security scanning in GitHub Actions
- [ ] add DEV branch and MAIN security
  - [ ] Create DEV branch
  - [ ] Configure branch protection for MAIN
- [ ] add feat / fix branch rules
  - [ ] Configure branch naming conventions
  - [ ] Set up auto-merge for fix branches
- [ ] split tests on merge to DEV
  - [ ] Configure separate test workflows for DEV branch
- [ ] artifact push/pull on merge to MAIN
- [ ] add tests etc. PRECOMMIT

----
# Setup OpenID Connect (OIDC) between AWS and GitHub Actions


## Terraform Configuration for Staging and Production Environments

This guide will help you configure separate AWS environments for staging and production using Terraform and GitHub Actions.

### Provider Configuration

```hcl
provider "aws" {
  region = "<AWS-REGION>"
}

# Staging Environment Role
resource "aws_iam_role" "github_actions_staging_role" {
  name = "GitHubActionsStagingRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS-ACCOUNT-ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:<YOUR-GITHUB-ORG>/<YOUR-REPO-NAME>:ref:refs/heads/stg"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "github_actions_staging_policy" {
  name   = "GitHubActionsStagingPolicy"
  role   = aws_iam_role.github_actions_staging_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::<YOUR-STAGING-BUCKET-NAME>",
        "arn:aws:s3:::<YOUR-STAGING-BUCKET-NAME>/*"
      ]
    }
  ]
}
EOF
}

# Production Environment Role
resource "aws_iam_role" "github_actions_production_role" {
  name = "GitHubActionsProductionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS-ACCOUNT-ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:<YOUR-GITHUB-ORG>/<YOUR-REPO-NAME>:ref:refs/heads/main"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "github_actions_production_policy" {
  name   = "GitHubActionsProductionPolicy"
  role   = aws_iam_role.github_actions_production_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::<YOUR-PRODUCTION-BUCKET-NAME>",
        "arn:aws:s3:::<YOUR-PRODUCTION-BUCKET-NAME>/*"
      ]
    }
  ]
}
EOF
}
```
## Instructions

1. **Replace Placeholders:**
   - `<AWS-REGION>`: Your AWS region (e.g., `us-west-2`).
   - `<YOUR-STAGING-BUCKET-NAME>`: The desired name for your staging S3 bucket.
   - `<YOUR-PRODUCTION-BUCKET-NAME>`: The desired name for your production S3 bucket.

2. **Customize Bucket Configuration:**
   - Adjust the `acl` (Access Control List) if needed (e.g., `public-read` for public access).
   - Add additional tags or configuration settings as required, such as versioning or logging.

3. **Apply the Configuration:**
   - Save the configuration to a `.tf` file (e.g., `buckets.tf`).
   - Run `terraform init` to initialize the configuration.
   - Run `terraform apply` to create both the staging and production S3 buckets in AWS.

   ```hcl
   provider "aws" {
     region = "<AWS-REGION>"
   }

   # Staging S3 Bucket
   resource "aws_s3_bucket" "staging_bucket" {
     bucket = "<YOUR-STAGING-BUCKET-NAME>"
     acl    = "private"

     tags = {
       Environment = "Staging"
     }
   }

   # Production S3 Bucket
   resource "aws_s3_bucket" "production_bucket" {
     bucket = "<YOUR-PRODUCTION-BUCKET-NAME>"
     acl    = "private"

     tags = {
       Environment = "Production"
     }
   }
   ```

## Terraform Configuration for Staging and Production Environments

### Staging Environment

```hcl
# Staging DynamoDB Table with KMS Encryption
resource "aws_dynamodb_table" "staging_terraform_locks" {
  count        = var.use_localstack ? 0 : 1
  name         = "fastapi-project-staging-terraform-locks-${var.aws_account_id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_key.arn
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "Staging"
    Purpose     = "Terraform State Locking"
  }
}

# Production DynamoDB Table with KMS Encryption
resource "aws_dynamodb_table" "production_terraform_locks" {
  count        = var.use_localstack ? 0 : 1
  name         = "fastapi-project-production-terraform-locks-${var.aws_account_id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_key.arn
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "Production"
    Purpose     = "Terraform State Locking"
  }
}

resource "aws_kms_key" "terraform_key" {
  description = "KMS key for encrypting Terraform state and lock data"
  deletion_window_in_days = 10

  tags = {
    Environment = "Shared"
    Purpose     = "Terraform Encryption"
  }
}
```



  