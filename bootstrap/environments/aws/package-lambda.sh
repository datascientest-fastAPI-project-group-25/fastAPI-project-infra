#!/bin/bash

# Ensure we're in the script's directory
cd "$(dirname "$0")"

# Create or clean the build directory
rm -rf build
mkdir -p build

# Copy the handler to build directory
cp notification_handler.js build/

# Create the ZIP file
cd build
zip -r ../notification_handler.zip .
cd ..

# Clean up build directory
rm -rf build

echo "Lambda function has been packaged to notification_handler.zip"