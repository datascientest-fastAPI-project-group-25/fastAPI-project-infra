#!/bin/bash
set -e

# Download TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Initialize TFLint with AWS plugin
tflint --init
