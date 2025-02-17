# syntax=docker/dockerfile:1.4
FROM --platform=$TARGETPLATFORM alpine:3.19 AS base

# Hadolint recommended practices
# DL3018: Pin versions for apk add
# DL3042: Avoid using sudo/doas
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    openssh-client \
    unzip \
    wget \
    file

# Detect and validate architecture
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
RUN echo "Target Platform: ${TARGETPLATFORM}" && \
    echo "Target OS: ${TARGETOS}" && \
    echo "Target Architecture: ${TARGETARCH}" && \
    uname -m && \
    case "${TARGETARCH}" in \
    amd64|arm64) \
        echo "Building for architecture: ${TARGETARCH}" ;; \
    *) \
        echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac

# Install Terraform
FROM base AS terraform-installer
ARG TERRAFORM_VERSION=1.10.5
ARG TARGETARCH
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}
RUN ARCH=$(case "${TARGETARCH}" in amd64) echo "amd64" ;; arm64) echo "arm64" ;; *) echo "amd64" ;; esac) && \
    echo "Downloading Terraform for architecture: ${ARCH}" && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip -O /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform && \
    /usr/local/bin/terraform version && \
    rm /tmp/terraform.zip

# Install OpenTofu
FROM base AS opentofu-installer
ARG OPENTOFU_VERSION=1.9.0
ARG TARGETARCH
ENV OPENTOFU_VERSION=${OPENTOFU_VERSION}
RUN ARCH=$(case "${TARGETARCH}" in amd64) echo "amd64" ;; arm64) echo "arm64" ;; *) echo "amd64" ;; esac) && \
    echo "Downloading OpenTofu for architecture: ${ARCH}" && \
    wget https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_${ARCH}.zip -O /tmp/tofu.zip && \
    unzip /tmp/tofu.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/tofu && \
    /usr/local/bin/tofu version && \
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
