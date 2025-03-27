locals {
  local_state_dir = "local-infra/s3-buckets/state"
  local_logs_dir  = "local-infra/s3-buckets/logs"
}

# Create local directories to simulate S3 buckets
resource "null_resource" "local_state_bucket" {
  provisioner "local-exec" {
    command     = "mkdir -p ${local.local_state_dir}"
    interpreter = ["bash", "-c"]
  }
}

resource "null_resource" "local_logs_bucket" {
  provisioner "local-exec" {
    command     = "mkdir -p ${local.local_logs_dir}"
    interpreter = ["bash", "-c"]
  }
}

# Create a README file to document the local setup
resource "null_resource" "local_setup_docs" {
  provisioner "local-exec" {
    command     = <<-EOT
      cat > README.md << 'EOF'
# Local Terraform State Setup

This directory contains a local simulation of AWS S3 and DynamoDB resources for Terraform state management.

## Directory Structure
- ${local.local_state_dir}: Simulates an S3 bucket for storing Terraform state files
- ${local.local_logs_dir}: Simulates an S3 bucket for storing access logs

## Usage
Use this local setup for development and testing without incurring AWS costs.
EOF
    EOT
    interpreter = ["bash", "-c"]
  }
}

# For actual AWS resources, uncomment these resources
# resource "aws_s3_bucket" "local_state" {
#   bucket = local.mock_bucket_name
# }
#
# resource "aws_dynamodb_table" "local_locks" {
#   name         = local.mock_table_name
#   hash_key     = "LockID"
#   billing_mode = "PAY_PER_REQUEST"
#
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
