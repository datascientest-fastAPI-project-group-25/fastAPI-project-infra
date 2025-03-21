# S3 bucket resource is commented out due to SCP restrictions
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "my-terraform-state-bucket-eu-west-2"
# 
#   # Enable versioning so we can track changes to our state files
#   versioning {
#     enabled = true
#   }
# 
#   # Enable server-side encryption
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# S3 backend configuration is commented out due to SCP restrictions
# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state-bucket-eu-west-2"
#     key    = "terraform.tfstate"
#     region = "eu-west-2"
#     encrypt = true
#   }
# }