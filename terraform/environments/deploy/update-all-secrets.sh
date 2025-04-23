#!/bin/bash

# Script to update sensitive variables in terraform.tfvars files

# Check if the script is run with the correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <db_username> <db_password>"
    exit 1
fi

DB_USERNAME=$1
DB_PASSWORD=$2

# Update staging environment
echo "Updating staging environment..."
sed -i "s/db_username = \"your_db_username\"/db_username = \"$DB_USERNAME\"/" stg/terraform.tfvars
sed -i "s/db_password = \"your_secure_password\"/db_password = \"$DB_PASSWORD\"/" stg/terraform.tfvars

# Update production environment
echo "Updating production environment..."
sed -i "s/db_username = \"your_db_username\"/db_username = \"$DB_USERNAME\"/" prod/terraform.tfvars
sed -i "s/db_password = \"your_secure_password\"/db_password = \"$DB_PASSWORD\"/" prod/terraform.tfvars

echo "All environments updated successfully!"
