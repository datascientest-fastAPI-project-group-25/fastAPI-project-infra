#!/bin/bash

set -e

# Run Checkov security scan on Terraform files
checkov -d . --quiet
