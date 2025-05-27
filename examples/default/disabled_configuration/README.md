<!-- BEGIN_TF_DOCS -->
# Terraform Module: Default Disabled Configuration Example

## Overview
> **Note:** This module demonstrates the usage of the `default` module with the feature flag disabled.

### 🔑 Key Features
- **Disabled Module Usage**: Illustrates how the module behaves when `is_enabled` is set to `false`.
- **No Resource Creation**: Shows that no resources are created when the module is disabled.
- **Output Validation**: Demonstrates that outputs still work correctly even when the module is disabled.

### 📋 Usage Guidelines
1. The `is_enabled` variable is set to `false` to disable the module.
2. This example is useful for testing conditional module behavior.
3. Validates that the module gracefully handles the disabled state.



## Variables

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether this module will be created or not. Useful for stack-composite<br/>modules that conditionally include resources provided by this module. | `bool` | `false` | no |
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