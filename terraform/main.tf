module "iam" {
  source = "./modules/iam"

  aws_account_id           = var.aws_account_id
  aws_region               = var.aws_region
  github_actions_role_name = "FastAPIProjectInfraRole"
  github_org               = "datascientest-fastAPI-project-group-25"
  github_repo              = "fastAPI-project-infra"
}

module "dynamodb" {
  source = "./modules/dynamoDB"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  table_name     = "terraform-lock"
}
