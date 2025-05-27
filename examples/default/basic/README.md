<!-- BEGIN_TF_DOCS -->
# Terraform Module: Default Basic Example

## Overview
> **Note:** This module demonstrates the basic usage of the `default` module.

### 🔑 Key Features
- **Basic Module Usage**: Illustrates the minimal configuration required to use the `default` module.
- **Conditional Creation**: Shows how to enable or disable the module using the `is_enabled` variable.

### 📋 Usage Guidelines
1. Set `is_enabled` to `true` or `false` to control module creation.
2. Provide `tags` for resource organization.



## Variables

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. Useful for stack-composite<br/>modules that conditionally include resources provided by this module. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_is_enabled"></a> [is\_enabled](#output\_is\_enabled) | Whether the module is enabled or not |
| <a name="output_tags_set"></a> [tags\_set](#output\_tags\_set) | The tags set for the module |

## Resources

## Resources

No resources.
<!-- END_TF_DOCS -->
