terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock"
  }
}