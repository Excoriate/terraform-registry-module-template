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
<!-- END_TF_DOCS -->
