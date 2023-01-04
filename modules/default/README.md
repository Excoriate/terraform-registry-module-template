<!-- BEGIN_TF_DOCS -->

[//]: # (FIXME: Remove, refactor or change. &#40;Template&#41;)
# ☁️ AWS Account Creator Module
## Description

This module creates one or many new AWS accounts, linked to either a new or existing AWS organization. It sets up service principals and organizational units if specified.
A summary of its main features:
* 🚀 Create multiple AWS accounts.
* 🚀 Create a new AWS organization or link to an existing one.
* 🚀 Add organisational units or create accounts directly linked to the root AWS organization.
* 🚀 Add and customize service principals.

---
## Example
Examples of this module's usage are available in the [examples](../../examples) folder.

```hcl
module "main_module" {
  source     = "../../../modules"
  is_enabled = var.is_enabled
  aws_org_config = {
    aws_accounts = [{
      name   = "account1",
      prefix = "prefix1",
      email  = "email1@domain1.com"
      },
      {
        name   = "account2",
        prefix = "prefix2",
        email  = "email2@domain2.com"
      }
    ]
  }
  aws_region = var.aws_region
}
```

For module composition, It's recommended to take a look at the module's `outputs` to understand what's available:
```hcl
output "is_enabled" {
  value       = var.is_enabled
  description = "Whether the module is enabled or not."
}

output "aws_region_for_deploy_this" {
  value       = local.aws_region_to_deploy
  description = "The AWS region where the module is deployed."
}

output "aws_org_principals" {
  value       = local.aws_org_principals
  description = "List of AWS Organization principals"
}

output "aws_accounts_to_create" {
  value       = local.aws_accounts
  description = "List of AWS accounts to create"
}

output "aws_org_units" {
  value       = local.aws_org_units
  description = "List of AWS Organization units"
}
```
---

## Module's documentation
(This documentation is auto-generated using [terraform-docs](https://terraform-docs.io))
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.48.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.account_with_org_unit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_account.account_without_org_unit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.48.0, < 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_org_config"></a> [aws\_org\_config](#input\_aws\_org\_config) | n/a | <pre>object({<br>    // Main org configuration<br>    feature_set                   = optional(string, "ALL")<br>    aws_service_access_principals = optional(list(string), [])<br>    // Organizational units configuration<br>    org_units = optional(list(string), [])<br>    // AWS accounts configuration<br>    aws_accounts = list(object({<br>      name                              = string<br>      email                             = string<br>      prefix                            = optional(string, "")<br>      enable_iam_user_access_to_billing = optional(string, "ALLOW")<br>      remove_from_org_in_deletion       = optional(bool, true)<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy the resources | `string` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. It is useful, for stack-composite<br>modules that conditionally includes resources provided by this module.. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_accounts_to_create"></a> [aws\_accounts\_to\_create](#output\_aws\_accounts\_to\_create) | List of AWS accounts to create |
| <a name="output_aws_org_principals"></a> [aws\_org\_principals](#output\_aws\_org\_principals) | List of AWS Organization principals |
| <a name="output_aws_org_units"></a> [aws\_org\_units](#output\_aws\_org\_units) | List of AWS Organization units |
| <a name="output_aws_region_for_deploy_this"></a> [aws\_region\_for\_deploy\_this](#output\_aws\_region\_for\_deploy\_this) | The AWS region where the module is deployed. |
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Whether the module is enabled or not. |
<!-- END_TF_DOCS -->
