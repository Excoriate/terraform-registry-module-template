# Terraform Module: Read AWS Account Metadata

## Overview
> **Note:** This simple module uses AWS data sources (`aws_caller_identity`, `aws_partition`, `aws_region`) to retrieve metadata about the current AWS environment (Account ID, ARN, User ID, Partition, Region Name, Region Description) where Terraform is executing. It provides these details as outputs for use in other modules or configurations, often useful in Terragrunt setups.

### 🔑 Key Features
- Retrieves current AWS Account ID.
- Retrieves current AWS Caller ARN and User ID.
- Retrieves current AWS Partition (e.g., `aws`, `aws-us-gov`).
- Retrieves current AWS Region name and description.
- No resources are created, only data sources are used.

### 📋 Usage Guidelines
1. Include the module in your Terraform configuration.
2. Access the desired metadata via the module's outputs (e.g., `module.read_aws_account.account_id`).

```hcl
module "account_info" {
  source = "../path/to/read-aws-account"
  # No inputs required beyond provider configuration
}

resource "aws_s3_bucket" "example" {
  # Example using an output from this module
  bucket = "my-bucket-${module.account_info.account_id}-${module.account_info.region_name}"
}
```

<!-- BEGIN_TF_DOCS -->
# Terraform Module: Read AWS Account Metadata

## Overview
> **Note:** This simple module uses AWS data sources (`aws_caller_identity`, `aws_partition`, `aws_region`) to retrieve metadata about the current AWS environment (Account ID, ARN, User ID, Partition, Region Name, Region Description) where Terraform is executing. It provides these details as outputs for use in other modules or configurations, often useful in Terragrunt setups.

### 🔑 Key Features
- Retrieves current AWS Account ID.
- Retrieves current AWS Caller ARN and User ID.
- Retrieves current AWS Partition (e.g., `aws`, `aws-us-gov`).
- Retrieves current AWS Region name and description.
- No resources are created, only data sources are used.

### 📋 Usage Guidelines
1. Include the module in your Terraform configuration.
2. Access the desired metadata via the module's outputs (e.g., `module.read_aws_account.account_id`).

```hcl
module "account_info" {
  source = "../path/to/read-aws-account"
  # No inputs required beyond provider configuration
}

resource "aws_s3_bucket" "example" {
  # Example using an output from this module
  bucket = "my-bucket-${module.account_info.account_id}-${module.account_info.region_name}"
}
```



## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.95.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Toggle module data source execution.<br/><br/>Use cases:<br/>- Conditional data source execution<br/>- Environment-specific deployments<br/>- Cost and resource management<br/><br/>Examples:<pre>hcl<br/># Disable all module data sources<br/>is_enabled = false<br/><br/># Enable module data sources (default)<br/>is_enabled = true</pre>🔗 References:<br/>- Terraform Variables: https://terraform.io/language/values/variables<br/>- Module Patterns: https://hashicorp.com/blog/terraform-module-composition | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tagging for organization and governance.<br/><br/>Key benefits:<br/>- Resource tracking<br/>- Cost allocation<br/>- Compliance management<br/><br/>Best practices:<br/>- Use lowercase, hyphen-separated keys<br/>- Include context (env, project, ownership)<br/><br/>Examples:<pre>hcl<br/>tags = {<br/>  environment = "production"<br/>  project     = "core-infra"<br/>  managed-by  = "terraform"<br/>}</pre>Note: This module creates no taggable resources, but this variable is included for consistency.<br/><br/>🔗 References:<br/>- AWS Tagging: https://aws.amazon.com/answers/account-management/aws-tagging-strategies/<br/>- Cloud Tagging: https://cloud.google.com/resource-manager/docs/best-practices-labels | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS Account ID number of the account that owns or contains the calling entity. |
| <a name="output_caller_arn"></a> [caller\_arn](#output\_caller\_arn) | The AWS ARN associated with the calling entity. |
| <a name="output_caller_user_id"></a> [caller\_user\_id](#output\_caller\_user\_id) | The unique identifier of the calling entity. |
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Indicates whether the data sources in this module were enabled (and therefore read). |
| <a name="output_partition"></a> [partition](#output\_partition) | The AWS partition in which the calling entity exists (e.g., `aws`, `aws-cn`, `aws-us-gov`). |
| <a name="output_region_description"></a> [region\_description](#output\_region\_description) | The description of the AWS Region (e.g., `US East (N. Virginia)`). |
| <a name="output_region_name"></a> [region\_name](#output\_region\_name) | The name of the AWS Region (e.g., `us-east-1`). |
<!-- END_TF_DOCS -->
