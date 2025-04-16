# Terraform configuration to delete the dev2 EKS cluster

provider "aws" {
  region = "us-east-1"
}

# Define the EKS cluster
resource "aws_eks_cluster" "dev2_cluster" {
  name     = "fastapi-project-eks-dev2"
  role_arn = "arn:aws:iam::575977136211:role/fastapi-project-eks-dev2-cluster-20250412070550256900000003"
  version  = "1.27"

  vpc_config {
    subnet_ids = [
      "subnet-0cac1f6178c83968e",
      "subnet-0ce9971c7e2da6ec2"
    ]
    security_group_ids = ["sg-037f4e7626e403de4"]
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}
