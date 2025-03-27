# Backend configuration for terraform state management
bucket         = "dst-project-group-25-terraform-state"
key            = "terraform.tfstate"
region         = "eu-west-2"
dynamodb_table = "terraform-state-lock"
encrypt        = true
