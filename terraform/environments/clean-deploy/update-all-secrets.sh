#!/bin/bash

# Script to update sensitive variables in terraform.tfvars files

# Check if the script is run with the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <github_token> <db_username> <db_password>"
    exit 1
fi

GITHUB_TOKEN=$1
DB_USERNAME=$2
DB_PASSWORD=$3

# Update development environment
echo "Updating development environment..."
sed -i "s/github_token = \"your_new_github_token\"/github_token = \"$GITHUB_TOKEN\"/" development/terraform.tfvars
sed -i "s/db_username = \"your_db_username\"/db_username = \"$DB_USERNAME\"/" development/terraform.tfvars
sed -i "s/db_password = \"your_secure_password\"/db_password = \"$DB_PASSWORD\"/" development/terraform.tfvars

# Update staging environment
echo "Updating staging environment..."
sed -i "s/github_token = \"your_new_github_token\"/github_token = \"$GITHUB_TOKEN\"/" staging/terraform.tfvars
sed -i "s/db_username = \"your_db_username\"/db_username = \"$DB_USERNAME\"/" staging/terraform.tfvars
sed -i "s/db_password = \"your_secure_password\"/db_password = \"$DB_PASSWORD\"/" staging/terraform.tfvars

# Update production environment
echo "Updating production environment..."
sed -i "s/github_token = \"your_new_github_token\"/github_token = \"$GITHUB_TOKEN\"/" production/terraform.tfvars
sed -i "s/db_username = \"your_db_username\"/db_username = \"$DB_USERNAME\"/" production/terraform.tfvars
sed -i "s/db_password = \"your_secure_password\"/db_password = \"$DB_PASSWORD\"/" production/terraform.tfvars

echo "All environments updated successfully!"
