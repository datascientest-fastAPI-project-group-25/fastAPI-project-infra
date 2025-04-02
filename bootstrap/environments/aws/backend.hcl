region         = "us-east-1"
bucket         = "fastapi-project-terraform-state-${AWS_ACCOUNT_ID}"
key            = "bootstrap/terraform.tfstate"
encrypt        = true
dynamodb_table = "terraform-state-lock"
