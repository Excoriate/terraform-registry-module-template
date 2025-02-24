# Terraform StyleGuide: Mandatory Conventions and Rules

## Core Ruleset: Fundamental Principles of Terraform Development

### Rules for Code Quality
1. **Enforce Consistency**: Mandate uniform code structure and style across all Terraform projects
2. **Prioritize Readability**: Craft clear, self-documenting code that communicates intent
3. **Implement Modularity**: Design infrastructure components for maximum reusability and clear separation of concerns
4. **Mandate Security**: Implement robust, proactive security practices in infrastructure code
5. **Ensure Reproducibility**: Guarantee predictable and consistent infrastructure deployment

## Styleguide: Code Structure Rules

### Rule: Project File Organization
**Requirement**: Strictly adhere to the following project structure:

```text
project/
├── main.tf           # Primary configuration entry point
├── variables.tf      # Global variable definitions
├── outputs.tf        # Project-level outputs
├── versions.tf       # Provider and Terraform version constraints
├── data.tf           # Data sources
├── locals.tf         # Local values
├── README.md         # Project documentation
```

### Rule: Naming Conventions
**Mandate**:
- Use lowercase with underscores for all file and resource names
- Enforce descriptive and consistent naming patterns
- Prioritize clarity and predictability in naming

#### Naming Examples
```hcl
# Compliant Naming
resource "aws_security_group" "web_server_http" { ... }
resource "azurerm_virtual_network" "primary_network" { ... }

# Non-Compliant (Avoid)
resource "aws_security_group" "sg1" { ... }
resource "azurerm_virtual_network" "vnet" { ... }
```

## Styleguide: Variable Management Rules

### Rule: Variable Definition Guidelines
**Mandatory Requirements**:
- Define all variables exclusively in `variables.tf`, never in `main.tf`
- Construct meaningful, descriptive variable names
- Provide comprehensive descriptions that explain the purpose, impact, and usage of the variable
- Implement strict type constraints, explicitly avoiding `any` type
- Apply validation blocks for enhanced input control
- Use `is_*_enabled` naming convention for feature flags

#### Rule: Variable Definition Example
```hcl
variable "log_group_retention_days" {
    type        = number
    description = "Determines how long CloudWatch Logs retains log events in the specified log group. This setting helps manage storage costs while ensuring compliance with data retention requirements. The retention period can be set from 1 day to 10 years (3650 days). Common retention periods are 30 days for operational logs, 90 days for compliance, or longer for audit purposes. After the specified period, CloudWatch Logs automatically deletes expired log events."
    default     = 30

    validation {
        condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_group_retention_days)
        error_message = "Log group retention days must be one of [0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653]."
    }
}
```

## Styleguide: Resource Configuration Rules

### Rule: Resource Naming Conventions
**Mandatory Guidelines**:
- Construct resource names that explicitly describe their purpose
- Maintain absolute consistency across the entire project
- Use `this` as the name for singleton resources
- Embed context and function within the resource name

### Rule: Conditional Resource Creation
**Requirement**: Utilize `is_*_enabled` flags in locals for managing complex, dynamic resource generation:

```hcl
locals {
    # Feature flags for resource creation
    is_kms_key_enabled    = var.is_enabled
    is_log_group_enabled  = var.is_enabled
    is_s3_bucket_enabled  = var.is_enabled
}

resource "aws_kms_key" "this" {
    count = local.is_kms_key_enabled ? 1 : 0

    description             = local.kms_key_description
    deletion_window_in_days = var.kms_key_deletion_window
    enable_key_rotation     = true
}
```

## Styleguide: Tagging Strategy Rules

### Rule: Resource Tagging
**Mandatory Approach**:
- Implement a uniform tagging mechanism across all resources
- Sanitize and normalize tags within `locals` before resource application

```hcl
locals {
    # Standardize tags with strict validation
    common_tags = {
        Environment = var.environment
        ManagedBy   = "Terraform"
        Project     = var.project_name
        CostCenter  = var.cost_center
    }
}
```

## Styleguide: Anti-Pattern Prevention Rules

### Prohibited Practices
- **Reject**: Using `count` for complex resource generation
- **Prohibit**: Hardcoding environment-specific values
- **Forbid**: Mixing resource types within the same module
- **Prevent**: Violating the Don't Repeat Yourself (DRY) principle
