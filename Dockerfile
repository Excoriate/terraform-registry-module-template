# syntax=docker/dockerfile:1.4
FROM alpine:3.19 AS base

# Hadolint recommended practices
# DL3018: Pin versions for apk add
# DL3042: Avoid using sudo/doas
RUN apk add --no-cache \
    bash=~5.2 \
    ca-certificates=~20230506 \
    curl=~8.5 \
    git=~2.43 \
    openssh-client=~9.5 \
    unzip=~6.0 \
    wget=~1.21

# Install Terraform
FROM base AS terraform-installer
ARG TERRAFORM_VERSION=1.10.5
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}
# Hadolint ignore=DL3020
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/terraform.zip
RUN unzip /tmp/terraform.zip -d /usr/local/bin/ && \
    rm /tmp/terraform.zip

# Install OpenTofu
FROM base AS opentofu-installer
ARG OPENTOFU_VERSION=1.9.0
ENV OPENTOFU_VERSION=${OPENTOFU_VERSION}
# Hadolint ignore=DL3020
ADD https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_amd64.zip /tmp/tofu.zip
RUN unzip /tmp/tofu.zip -d /usr/local/bin/ && \
    rm /tmp/tofu.zip

# Final stage
FROM base

# Create a non-root user with a specific UID/GID
ARG UID=1000
ARG GID=1000
RUN addgroup -S -g ${GID} tfuser && \
    adduser -S -u ${UID} -G tfuser tfuser

# Copy binaries from previous stages
COPY --from=terraform-installer --chown=tfuser:tfuser /usr/local/bin/terraform /usr/local/bin/terraform
COPY --from=opentofu-installer --chown=tfuser:tfuser /usr/local/bin/tofu /usr/local/bin/tofu

# Set working directory and user
WORKDIR /workspace
USER tfuser

# Mount point for repository
VOLUME ["/workspace"]

# Default entrypoint with both Terraform and OpenTofu available
ENTRYPOINT ["/bin/bash"]

# Labels for version information and best practices
LABEL org.opencontainers.image.version=${TERRAFORM_VERSION} \
      org.opencontainers.image.version=${OPENTOFU_VERSION} \
      org.opencontainers.image.authors="Your Organization" \
      org.opencontainers.image.description="Terraform and OpenTofu CLI tools"
