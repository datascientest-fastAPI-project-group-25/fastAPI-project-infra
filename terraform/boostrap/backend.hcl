bucket         = "terraform-state-bucket"
key            = "bootstrap/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "s3-lock-table"
encrypt        = true
