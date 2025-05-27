# Terraform Environment Variables Guide

This guide provides comprehensive documentation for all Terraform environment variables, validated against official HashiCorp documentation and provider sources.

## Table of Contents

- [Quick Start](#quick-start)
- [Core Terraform Variables](#core-terraform-variables)
- [HCP Terraform/Cloud Variables](#hcp-terraformcloud-variables)
- [Input Variables (TF_VAR_*)](#input-variables-tf_var_)
- [AWS Provider Variables](#aws-provider-variables)
- [Other Provider Variables](#other-provider-variables)
- [CI/CD Integration](#cicd-integration)
- [Variable Precedence](#variable-precedence)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Quick Start

This project uses Justfile with `set dotenv-load` to automatically load environment variables from `.env` files. 

1. Copy `.env.example` to `.env`
2. Uncomment and set required variables
3. Run Terraform commands via Justfile recipes

```bash
# Example setup
cp .env.example .env
# Edit .env with your values
just terraform-plan  # Uses loaded environment variables
```

## Core Terraform Variables

### Logging and Debugging

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `TF_LOG` | Enable detailed logging | `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`, `off` | unset |
| `TF_LOG_PATH` | Log file location (requires TF_LOG) | File path | stderr |
| `TF_LOG_CORE` | Separate logging for Terraform core | Same as TF_LOG | unset |
| `TF_LOG_PROVIDER` | Separate logging for providers | Same as TF_LOG | unset |

```bash
# Enable trace logging
export TF_LOG=TRACE
export TF_LOG_PATH=./terraform.log

# Debug core issues specifically
export TF_LOG_CORE=DEBUG
export TF_LOG_PROVIDER=INFO
```

### Input and Automation

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `TF_INPUT` | Disable interactive prompts | `false`, `0` | true |
| `TF_IN_AUTOMATION` | Adjust output for CI/automation | Any non-empty value | unset |

```bash
# CI/automation setup
export TF_INPUT=false
export TF_IN_AUTOMATION=1
```

### Workspace and Configuration

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `TF_WORKSPACE` | Select Terraform workspace | Workspace name | `default` |
| `TF_DATA_DIR` | Override .terraform directory | Directory path | `.terraform` |
| `TF_CLI_CONFIG_FILE` | Custom CLI config file | File path | `~/.terraformrc` |

```bash
# Multi-environment setup
export TF_WORKSPACE=development
export TF_DATA_DIR=/custom/terraform/data
```

### Plugin and Provider Management

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `TF_PLUGIN_CACHE_DIR` | Provider plugin cache directory | Directory path | unset |
| `TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE` | Allow cache to break lock file | `true`, `false` | `false` |

```bash
# Enable plugin caching
export TF_PLUGIN_CACHE_DIR=$HOME/.terraform.d/plugin-cache
```

### Registry Configuration

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `TF_REGISTRY_DISCOVERY_RETRY` | Max retry attempts | Number | 3 |
| `TF_REGISTRY_CLIENT_TIMEOUT` | Client timeout (seconds) | Number | 10 |

### State Management

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `TF_STATE_PERSIST_INTERVAL` | State persistence interval (seconds) | Number ≥ 20 | 20 |

### CLI Arguments

| Variable | Description | Example |
|----------|-------------|---------|
| `TF_CLI_ARGS` | Global CLI arguments | `-parallelism=10` |
| `TF_CLI_ARGS_init` | Arguments for init command | `-upgrade` |
| `TF_CLI_ARGS_plan` | Arguments for plan command | `-refresh=false` |
| `TF_CLI_ARGS_apply` | Arguments for apply command | `-auto-approve=false` |

```bash
# Command-specific arguments
export TF_CLI_ARGS_plan="-refresh=false -parallelism=5"
export TF_CLI_ARGS_apply="-parallelism=10"
```

## HCP Terraform/Cloud Variables

### Organization and Project

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `TF_CLOUD_ORGANIZATION` | HCP Terraform organization | Yes* | `my-organization` |
| `TF_CLOUD_HOSTNAME` | HCP Terraform hostname | No | `app.terraform.io` |
| `TF_CLOUD_PROJECT` | HCP Terraform project | No | `my-project` |

*Required when using cloud block without explicit configuration

### Workspace Selection

| Variable | Description | Note |
|----------|-------------|------|
| `TF_WORKSPACE` | Single workspace name | Alternative to cloud block config |

### HCP Terraform Specific

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `TFE_PARALLELISM` | HCP Terraform run parallelism | 1-256 | 10 |

```bash
# HCP Terraform setup
export TF_CLOUD_ORGANIZATION=my-company
export TF_CLOUD_PROJECT=infrastructure
export TF_WORKSPACE=production
```

## Input Variables (TF_VAR_*)

Environment variables prefixed with `TF_VAR_` become Terraform input variables.

### Simple Variables

```bash
# String variables
export TF_VAR_region=us-west-2
export TF_VAR_environment=production
export TF_VAR_instance_type=t3.medium

# Number variables
export TF_VAR_instance_count=3
export TF_VAR_port=8080

# Boolean variables
export TF_VAR_enable_monitoring=true
export TF_VAR_create_vpc=false
```

### Complex Variables

```bash
# List variables
export TF_VAR_availability_zones='["us-west-2a", "us-west-2b", "us-west-2c"]'
export TF_VAR_allowed_cidrs='["10.0.0.0/8", "172.16.0.0/12"]'

# Map variables
export TF_VAR_tags='{"Environment": "production", "Team": "platform", "Cost-Center": "engineering"}'
export TF_VAR_instance_sizes='{"small": "t3.micro", "medium": "t3.small", "large": "t3.medium"}'

# Object variables
export TF_VAR_database_config='{"engine": "postgres", "version": "13.7", "instance_class": "db.t3.micro"}'
```

## AWS Provider Variables

### 🚨 Critical Configuration

```bash
# REQUIRED for AWS_PROFILE to work with Terraform
# This is poorly documented but essential
export AWS_SDK_LOAD_CONFIG=1
```

### Core Credentials

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG...` |
| `AWS_SESSION_TOKEN` | Temporary session token | For assumed roles |

### Region Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_DEFAULT_REGION` | Default AWS region | `us-west-2` |
| `AWS_REGION` | AWS region (alternative) | `us-west-2` |

### Profile and Configuration Files

| Variable | Description | Default |
|----------|-------------|---------|
| `AWS_PROFILE` | AWS profile name | `default` |
| `AWS_SHARED_CREDENTIALS_FILE` | Credentials file path | `~/.aws/credentials` |
| `AWS_CONFIG_FILE` | Config file path | `~/.aws/config` |

```bash
# Profile-based authentication (RECOMMENDED)
export AWS_SDK_LOAD_CONFIG=1  # CRITICAL!
export AWS_PROFILE=production
```

### Account and Endpoint Configuration

| Variable | Description | Values |
|----------|-------------|---------|
| `AWS_ACCOUNT_ID` | AWS account ID | `123456789012` |
| `AWS_ACCOUNT_ID_ENDPOINT_MODE` | Account-based endpoints | `preferred`, `disabled`, `required` |
| `AWS_ENDPOINT_URL` | Global endpoint override | URL |
| `AWS_ENDPOINT_URL_<SERVICE>` | Service-specific endpoint | URL |
| `AWS_IGNORE_CONFIGURED_ENDPOINT_URLS` | Ignore custom endpoints | `true`, `false` |

### Security and Compliance

| Variable | Description | Values |
|----------|-------------|---------|
| `AWS_USE_FIPS_ENDPOINT` | Use FIPS endpoints | `true`, `false` |
| `AWS_USE_DUALSTACK_ENDPOINT` | Use dual-stack (IPv4/IPv6) | `true`, `false` |
| `AWS_CA_BUNDLE` | Custom CA bundle | File path |

### Advanced Configuration

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `AWS_MAX_ATTEMPTS` | Retry attempts | Number | 3 |
| `AWS_RETRY_MODE` | Retry mode | `legacy`, `standard`, `adaptive` | `legacy` |
| `AWS_REQUEST_CHECKSUM_CALCULATION` | Request checksums | `when_supported`, `when_required` | `when_supported` |
| `AWS_RESPONSE_CHECKSUM_VALIDATION` | Response validation | `when_supported`, `when_required` | `when_supported` |

### EC2 and Metadata

| Variable | Description | Values | Default |
|----------|-------------|---------|---------|
| `AWS_EC2_METADATA_DISABLED` | Disable metadata service | `true`, `false` | `false` |
| `AWS_METADATA_SERVICE_NUM_ATTEMPTS` | Metadata retry attempts | Number | 1 |
| `AWS_METADATA_SERVICE_TIMEOUT` | Metadata timeout (seconds) | Number | 1 |

### STS Configuration

| Variable | Description | Values |
|----------|-------------|---------|
| `AWS_STS_REGIONAL_ENDPOINTS` | STS endpoint usage | `legacy`, `regional` |
| `AWS_ROLE_ARN` | Role ARN for web identity | `arn:aws:iam::...` |
| `AWS_ROLE_SESSION_NAME` | Session name | String |
| `AWS_WEB_IDENTITY_TOKEN_FILE` | Token file path | File path |

## Other Provider Variables

### Azure (ARM)

```bash
# Service Principal Authentication
export ARM_SUBSCRIPTION_ID=12345678-1234-9876-4563-123456789012
export ARM_CLIENT_ID=12345678-1234-9876-4563-123456789012
export ARM_CLIENT_SECRET=your-client-secret
export ARM_TENANT_ID=12345678-1234-9876-4563-123456789012

# Environment
export ARM_ENVIRONMENT=Public  # Public, UsGovernment, German, China

# Alternative Authentication Methods
export ARM_USE_MSI=true        # Managed Service Identity
export ARM_USE_CLI=true        # Azure CLI
export ARM_USE_OIDC=true       # OIDC
export ARM_OIDC_TOKEN=token
```

### Google Cloud Platform

```bash
# Service Account
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# Project and Location
export GOOGLE_PROJECT=my-gcp-project
export GOOGLE_REGION=us-central1
export GOOGLE_ZONE=us-central1-a

# Impersonation
export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=sa@project.iam.gserviceaccount.com
```

### Kubernetes

```bash
# Configuration
export KUBE_CONFIG_PATH=$HOME/.kube/config
export KUBE_CTX=my-cluster-context
export KUBE_NAMESPACE=default
export KUBE_IN_CLUSTER_CONFIG=false
```

### HashiCorp Vault

```bash
# Connection
export VAULT_ADDR=https://vault.example.com:8200
export VAULT_TOKEN=your-vault-token
export VAULT_NAMESPACE=my-namespace

# TLS Configuration
export VAULT_CACERT=/path/to/ca.pem
export VAULT_CLIENT_CERT=/path/to/client.pem
export VAULT_CLIENT_KEY=/path/to/client-key.pem
export VAULT_SKIP_VERIFY=false
```

### HashiCorp Consul

```bash
# Connection
export CONSUL_HTTP_ADDR=localhost:8500
export CONSUL_DATACENTER=dc1

# Authentication
export CONSUL_HTTP_TOKEN=your-consul-token
export CONSUL_HTTP_AUTH=username:password

# TLS
export CONSUL_HTTP_SSL=true
export CONSUL_CACERT=/path/to/ca.pem
```

## CI/CD Integration

### GitHub Actions

```yaml
env:
  TF_IN_AUTOMATION: 1
  TF_INPUT: false
  AWS_SDK_LOAD_CONFIG: 1
  AWS_PROFILE: github-actions
```

### GitLab CI

```yaml
variables:
  TF_IN_AUTOMATION: "1"
  TF_INPUT: "false"
  TF_LOG: "INFO"
```

### Jenkins

```groovy
environment {
    TF_IN_AUTOMATION = '1'
    TF_INPUT = 'false'
    AWS_SDK_LOAD_CONFIG = '1'
}
```

## Variable Precedence

Terraform uses the following precedence order (highest to lowest):

1. **Command line options**
   ```bash
   terraform apply -var="region=us-east-1"
   ```

2. **Environment variables**
   ```bash
   export TF_VAR_region=us-west-2
   ```

3. **terraform.tfvars files**
   ```hcl
   region = "us-central1"
   ```

4. **Variable defaults**
   ```hcl
   variable "region" {
     default = "eu-west-1"
   }
   ```

### Special Cases

- `TF_VAR_*` variables override `.tfvars` files
- Command-specific `TF_CLI_ARGS_*` override global `TF_CLI_ARGS`
- Provider authentication follows provider-specific precedence

## Best Practices

### Security

1. **Never commit secrets to version control**
   ```bash
   # Use .env for local development
   echo ".env" >> .gitignore
   ```

2. **Use secret management systems**
   ```bash
   # Example with HashiCorp Vault
   export VAULT_TOKEN=$(vault write -field=token auth/aws/login role=terraform)
   ```

3. **Prefer IAM roles over access keys**
   ```bash
   # Use instance profiles, ECS task roles, etc.
   export AWS_SDK_LOAD_CONFIG=1  # Enable profile support
   ```

### Development Workflow

1. **Environment-specific configuration**
   ```bash
   # Use different .env files per environment
   cp .env.example .env.development
   cp .env.example .env.production
   ```

2. **Justfile integration**
   ```justfile
   # The `set dotenv-load` directive automatically loads .env files
   set dotenv-load
   
   terraform-plan env="development":
       @echo "Planning for {{env}} environment"
       terraform plan
   ```

3. **Variable validation**
   ```bash
   # Test variable loading
   export TF_LOG=DEBUG
   terraform plan -no-color | grep "TF_VAR"
   ```

### Provider Configuration

1. **AWS Profile Setup**
   ```bash
   # ALWAYS set this for profile support
   export AWS_SDK_LOAD_CONFIG=1
   export AWS_PROFILE=your-profile
   ```

2. **Multi-region deployments**
   ```bash
   # Use provider aliases in Terraform config
   export TF_VAR_primary_region=us-east-1
   export TF_VAR_secondary_region=us-west-2
   ```

## Troubleshooting

### Common Issues

#### AWS Profile Not Working
```bash
# Problem: AWS_PROFILE is set but Terraform can't authenticate
# Solution: Enable SDK config loading
export AWS_SDK_LOAD_CONFIG=1
export AWS_PROFILE=your-profile
```

#### Environment Variables Not Loading
```bash
# Check if variables are set
env | grep TF_

# Test with simple plan
export TF_LOG=DEBUG
terraform plan
```

#### HCP Terraform Connection Issues
```bash
# Verify cloud block environment variables
export TF_CLOUD_ORGANIZATION=my-org
export TF_WORKSPACE=my-workspace

# Test with empty cloud block
terraform {
  cloud {}
}
```

### Debugging Commands

```bash
# Enable detailed logging
export TF_LOG=TRACE
export TF_LOG_PATH=debug.log

# Check provider authentication
terraform plan -refresh=false

# Validate configuration
terraform validate

# Show effective configuration
terraform show -json | jq '.configuration'
```

### Provider-Specific Debugging

#### AWS
```bash
# Test AWS credentials independently
aws sts get-caller-identity

# Check profile configuration
aws configure list --profile your-profile

# Verify region setting
aws configure get region --profile your-profile
```

#### Azure
```bash
# Test Azure authentication
az account show

# List available subscriptions
az account list
```

#### Google Cloud
```bash
# Test GCP authentication
gcloud auth list

# Check current project
gcloud config get-value project
```

## Reference Links

- [Official Terraform Environment Variables](https://developer.hashicorp.com/terraform/cli/config/environment-variables)
- [HCP Terraform Variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Environment Variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
- [Terraform Variable Precedence](https://developer.hashicorp.com/terraform/language/values/variables#variable-definition-precedence)

---

**Last Updated**: January 2025  
**Terraform Version**: 1.12.x  
**Sources**: Official HashiCorp documentation, AWS provider docs, community best practices 
