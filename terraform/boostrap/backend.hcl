bucket         = "fastapi-project-terraform-state-${var.aws_account_id}"
key            = "bootstrap/terraform.tfstate"
region         = var.aws_region
dynamodb_table = var.dynamodb_table_name
encrypt        = true
