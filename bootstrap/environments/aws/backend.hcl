region         = var.aws_region
key            = "bootstrap/terraform.tfstate"
encrypt        = true
dynamodb_table = var.dynamodb_table_name