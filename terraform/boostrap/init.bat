@echo off
setlocal

REM Default to local environment
set "ENV=%1"
if "%ENV%"=="" set "ENV=local"

if "%ENV%"=="local" (
    echo Initializing Terraform with LocalStack backend...
    terraform init -reconfigure
) else if "%ENV%"=="aws" (
    echo Initializing Terraform with AWS S3 backend...
    terraform init -reconfigure -backend=true -backend-config=backend.hcl
) else (
    echo Unknown environment: %ENV%
    echo Usage: init.bat [local|aws]
    exit /b 1
)
