<!-- BEGIN_TF_DOCS -->
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

Examples of this module's usage are available in the [examples](./examples) folder.

```hcl
module "main_module" {
  source     = "../../../modules/default"
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

output "tags_set"{
  value       = var.tags
  description = "The tags set for the module."
}

/*
-------------------------------------
Custom outputs
-------------------------------------
*/
// FIXME: Remove, refactor or change. (Template)
```

---

## Module's documentation

(This documentation is auto-generated using [terraform-docs](https://terraform-docs.io))

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_string.random_text](https://registry.terraform.io/providers/hashicorp/random/3.4.3/docs/resources/string) | resource |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.48.0, < 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy the resources | `string` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. It is useful, for stack-composite<br>modules that conditionally includes resources provided by this module.. | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region_for_deploy_this"></a> [aws\_region\_for\_deploy\_this](#output\_aws\_region\_for\_deploy\_this) | The AWS region where the module is deployed. |
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Whether the module is enabled or not. |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The tags set for the module. |
<!-- END_TF_DOCS -->
