# VPC resources are commented out due to SCP restrictions
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
#   tags = { Name = "MyVPC" }
# }
# 
# resource "aws_subnet" "subnet" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "eu-west-2a"
# }
# 
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.main.id
# }