# Terraform Module: Random String Generator

## Overview
> **Note:** This module generates a random string using the `hashicorp/random` provider, suitable for use as a unique suffix or identifier.

### 🔑 Key Features
- **Random String Generation**: Creates a random string based on specified constraints.
- **Configurable Length**: Control the exact length of the generated string via the `length` variable.
- **Case Control**: Independently enable/disable lowercase (`lower`) and uppercase (`upper`) characters.
- **Conditional Creation**: Enable or disable the creation of the random string using the `is_enabled` flag.

### 📋 Usage Guidelines
1. Optionally, set `is_enabled` to `false` to disable the module (default: true).
2. Optionally, specify the desired `length` (default: 8).
3. Optionally, set `lower` to `false` to exclude lowercase letters (default: true).
4. Optionally, set `upper` to `false` to exclude uppercase letters (default: true).
5. Use the `random_string` output (will be `null` if `is_enabled` is `false`).
> Note: Numeric and special characters are always excluded in this simplified module version.

<!-- BEGIN_TF_DOCS -->
# Terraform Module: Random String Generator

## Overview
> **Note:** This module generates a random string using the `hashicorp/random` provider, suitable for use as a unique suffix or identifier.

### 🔑 Key Features
- **Random String Generation**: Creates a random string based on specified constraints.
- **Configurable Length**: Control the exact length of the generated string via the `length` variable.
- **Case Control**: Independently enable/disable lowercase (`lower`) and uppercase (`upper`) characters.

### 📋 Usage Guidelines
1. Optionally, set `is_enabled` to `false` to disable the module (default: true).
2. Optionally, specify the desired `length` (default: 8).
3. Optionally, set `lower` to `false` to exclude lowercase letters (default: true).
4. Optionally, set `upper` to `false` to exclude uppercase letters (default: true).
5. Use the `random_string` output (will be `null` if `is_enabled` is `false`).
> Note: Numeric and special characters are always excluded in this simplified module version.



## Variables

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Controls whether the random string resource is created.<br/>Set to `false` to prevent the random string from being generated.<br/><br/>**Purpose**: Allows conditional creation of the random string.<br/>**Impact**: If `false`, the `random_string` output will be `null`.<br/>**Default**: `true` (module is enabled by default) | `bool` | `true` | no |
| <a name="input_length"></a> [length](#input\_length) | Specifies the exact length of the random string to be generated.<br/><br/>**Purpose**: Controls the length of the output random string.<br/>**Impact**: Directly influences the length of the `random_string` output.<br/>**Default**: `8`<br/>**Constraints**: Must be a positive integer. The `random` provider might have practical upper limits. | `number` | `8` | no |
| <a name="input_lower"></a> [lower](#input\_lower) | Specifies whether lowercase letters are allowed in the generated random string.<br/><br/>**Purpose**: Controls the character set used for generation.<br/>**Impact**: Affects the possible characters in the `random_string` output.<br/>**Default**: `true` (lowercase letters are included by default) | `bool` | `true` | no |
| <a name="input_upper"></a> [upper](#input\_upper) | Specifies whether uppercase letters are allowed in the generated random string.<br/><br/>**Purpose**: Controls the character set used for generation.<br/>**Impact**: Affects the possible characters in the `random_string` output.<br/>**Default**: `true` (uppercase letters are included by default) | `bool` | `true` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_random_string"></a> [random\_string](#output\_random\_string) | The generated random string based on the specified length, lower, and upper character constraints. Returns 'null' if 'is\_enabled' is false. |

## Resources

## Resources

| Name | Type |
|------|------|
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
<!-- END_TF_DOCS -->
