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
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_DEFAULT_REGION="us-east-1"
ENV AWS_ACCOUNT_ID=""
ENV PROJECT_NAME="fastapi-project"
ENV ENVIRONMENT="dev"

# Entry point
ENTRYPOINT ["/bin/bash"]