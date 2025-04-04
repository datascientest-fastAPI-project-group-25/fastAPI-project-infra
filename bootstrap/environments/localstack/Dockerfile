FROM hashicorp/terraform:1.5.7

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    python3 \
    py3-pip \
    unzip \
    git

# Install AWS CLI
RUN pip3 install --no-cache-dir awscli

# Set working directory
WORKDIR /app

# Copy necessary files
COPY . /app/

# Set environment variables
ENV AWS_ACCESS_KEY_ID="test"
ENV AWS_SECRET_ACCESS_KEY="test"
ENV AWS_DEFAULT_REGION="eu-west-2"
ENV AWS_ACCOUNT_ID="000000000000"
ENV PROJECT_NAME="fastapi-project"
ENV ENVIRONMENT="dev"
ENV LOCALSTACK_ENDPOINT="http://localstack:4566"

# Entry point
ENTRYPOINT ["/bin/bash"]