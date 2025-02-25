## Table of Contents

- [Terraform StyleGuide: Mandatory Conventions and Rules](#terraform-styleguide-mandatory-conventions-and-rules)
  - [Core Ruleset: Fundamental Principles of Terraform Development](#core-ruleset-fundamental-principles-of-terraform-development)
    - [Rules for Code Quality](#rules-for-code-quality)
  - [Styleguide: Code Structure Rules](#styleguide-code-structure-rules)
    - [Rule: Project File Organization](#rule-project-file-organization)
    - [Rule: General Naming Conventions](#rule-general-naming-conventions)
    - [Rule: Comments](#rule-comments)
  - [Styleguide: Variables](#styleguide-variables)
    - [Rule: Variable Definition Guidelines](#rule-variable-definition-guidelines)
    - [Rule: Variable Description, and Self-Documentation](#rule-variable-description-and-self-documentation)
  - [Styleguide: Resource Configuration Rules](#styleguide-resource-configuration-rules)
    - [Rule: Resource Naming Conventions](#rule-resource-naming-conventions)
    - [Rule: Feature Flags](#rule-feature-flags)
    - [Rule: Conditional Resource Creation](#rule-conditional-resource-creation)
  - [Styleguide: Tagging Strategy Rules](#styleguide-tagging-strategy-rules)
    - [Rule: Resource Tagging](#rule-resource-tagging)

# Terraform StyleGuide: Mandatory Conventions and Rules

## Core Ruleset: Fundamental Principles of Terraform Development

### Rules for Code Quality

1. **Enforce Consistency**: Mandate uniform code structure and style across all Terraform projects
2. **Prioritize Readability**: Craft clear, self-documenting code that communicates intent
3. **Implement Modularity**: Design infrastructure components for maximum reusability and clear separation of concerns
4. **Mandate Security**: Implement robust, proactive security practices in infrastructure code
5. **Ensure Reproducibility**: Guarantee predictable and consistent infrastructure deployment
6.  **Simplify Complexity**: Keep the module simple, composable and maintainable. Avoid bigger modules with too many features.

## Styleguide: Code Structure Rules

### Rule: Project File Organization

**Rule**: Strictly adhere to the following project structure for the actual Terraform module:

```text
/modules/[module-name]/
├── main.tf          # Primary resource definitions
├── locals.tf        # Complex computations and transformations
├── data.tf          # External data source retrieval
├── variables.tf     # Input variable definitions
├── outputs.tf       # Module output definitions
├── versions.tf      # Provider and Terraform version constraints
├── providers.tf     # Optional provider configurations
├── README.md        # Comprehensive module documentation
├── .terraform-docs.yml # Documentation generation configuration
├── .tflint.hcl      # Terraform linting rules
```

**Important Notes**:

- Some modules will require specialised files, such as `iam_roles.tf` for IAM role management, or `data.tf` for external data source retrieval. This is only permitted for modules which provide a lot of resources, so grouping them into contextual files (per resource type, or platform ocntext) is encouraged, keeping the `main.tf` file clean and readable, and only concerned with the core resource definitions. This only is applicable if the amount of resources is high, and there are several resources that can be grouped into a contextual file.
- Don't create the `providers.tf` file. It's only meant for root modules.
- Always include a `.terraform-docs.yml` file in every module root directory, to favour automated documentation generation using the existing Justfile, or through CI.
- Always include a `.tflint.hcl` file in every module root directory, to favour automated linting using the existing Justfile, or through CI.

### Rule: General Naming Conventions

- Use lowercase with underscores for all file and resource names
- Enforce descriptive and consistent naming patterns. Use `snake_case` for all file and resource names.
- Prioritize clarity and predictability in naming, with readability, and an idiomatic code style
- If the name given isn't clear, and require a comment to explain it, it's not a good name.

A complaint, and non compliant naming examples:

```hcl
# Compliant Naming
resource "aws_security_group" "web_server_http" { ... }
resource "azurerm_virtual_network" "primary_network" { ... }

# Non-Compliant (Avoid)
resource "aws_security_group" "sg1" { ... }
resource "azurerm_virtual_network" "vnet" { ... }
```

### Rule: Comments

- Use comments to explain complex logic, and provide clear instructions for maintainers and contributors.
- Use comments to explain oppinionated decisions, and provide context for valid values, specific configurations for resources, or specific parts of the code that favour maintainability, and readability.
- Use a professional writing style. Use emojis only when necessary.

A good comment example:

```hcl
  ###################################
  # Feature Flags ⛳️
  # ----------------------------------------------------
  #
  # These flags are used to enable or disable certain features.
  # 1. `is_queue_enabled` - Flag to enable or disable the SQS queue that's built-in to the module.
  # 2. `is_dlq_enabled` - Flag to enable or disable the Dead Letter Queue (DLQ) that's built-in to the module.
  #
  ###################################
  is_queue_enabled = true
  is_dlq_enabled = true
```

---

## Styleguide: Variables

### Rule: Variable Definition Guidelines

- Define all variables exclusively in `variables.tf`, never in `main.tf` or in any other file.
- You MUST creat a complete description of the variable should be verbose. It should explain the purpose, impact, and usage of the variable, its default values, what they mean in the context of the module and the resource(s) they are used in, and how they can be overridden or extended.
- Implement strict type constraints, explicitly avoiding `any` type.
- Apply validation blocks for enhanced input control. Ensure the validations are clear, simple, and reliable. Avoid at all cost flaky, complex, unnecesary or ambiguous validations. 
- Use `is_SOMETHINGHERE_enabled` naming convention for feature flags for specific resources, or particular features provided by the module.
- Reserve the `is_enabled` variable for the module's activation/deactivation flag.
- Create all the input variables with idiomatic names. By just reading the variable name, you can understand what it does, and what it expects as input.
- Use meaniful default values when possible. These default values should be the recommended, safe, and secure configurations for the module, and for the resource(s) it is used in.
- Whenever `null` is set as a default for a variable, always normalise and validate the value to `null` before using it (in the `locals.tf` file).
- Use `optional()` for complex, optional variables, and `list(object())` for complex list structures. When using `optional()`, always normalise and validate the value to `null` before using it (in the `locals.tf` file). if possible, use `optional() with the built-in default value.

### Rule: Variable Description, and Self-Documentation

- Use always the `<<-DESC` syntax for all variable descriptions that due to their complexity, or impact in the module's behaviour, they are not self-explanatory, or are bigger (E.g.: using object or list structures, with multiple values, or complex validations).
- Include always this information in the variable description:
  - Variable purpose
  - Default values, and what they mean comprehensively described
  - Impact on the module's behaviour, and in the resource(s) it is used in
  - References to the provider documentation, and the Terraform Registry documentation
  - Usage examples (if applicable)

A good variable description example:

```hcl
variable "log_group_configuration" {
    type        = object({
        retention_days = number
        kms_key_id     = string
    })
    description = <<-DESC
    This variable configures the CloudWatch Logs retention policy for the module's log group. It controls the retention period, and the encryption configuration for the log group. The retention period can be set from 1 day to 10 years (3650 days). Common retention periods are 30 days for operational logs, 90 days for compliance, or longer for audit purposes. After the specified period, CloudWatch Logs automatically deletes expired log events.
    
    **RETENTION PERIOD CONSTRAINTS**:
    - Minimum: 1 day
    - Maximum: 10 years (3650 days)
    
    **RECOMMENDED RETENTION STRATEGIES**:
    - Operational Logs: 30 days
    - Compliance Logs: 90 days
    - Audit Logs: Extended periods

    **AUTOMATIC DELETION ENFORCEMENT**:
    - Expired log events AUTOMATICALLY purged
    DESC
    default     = {
        retention_days = 30
        kms_key_id     = null
    }
}
```

---

## Styleguide: Resource Configuration Rules

### Rule: Resource Naming Conventions

- Use `this` as the name for singleton resources, or for default resources as part of the module.
- Construct resource names that explicitly describe their purpose
- Maintain absolute consistency across the entire project
- Ensure that where there are multiple resources of the same type, they're named consistently and clearly, using an idiomatic prefix that gives context about the resource, their purpose in the module, and their relationship to other resources.

### Rule: Feature Flags

- The `is_enabled` variable is reserved for the module's activation/deactivation flag. It's the module's feature flag, and it's used to conditionally create all the resources in the module.
- Use `is_SOMETHINGHERE_enabled` naming convention for feature flags for specific resources, or particular features provided by the module.
- Support incremental, composable module architecture. Feature flags can be computed from other feature flags, or for a oppinionated configuration, or for a specific resource. All thse computations, calculations, and logic should be encapsulated in the `locals.tf` file.
- Never create or compute feature flags in the `count` or `for_each` blocks in the resource definitions. Resources should be kept as simple as possible, and only concerned with the core resource definition.

Example:

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

### Rule: Conditional Resource Creation

- Utilize `is_SOMETHINGHERE_enabled` flags in locals for managing complex, dynamic resource generation:
- If the flag is computed from an input variable, use the `local.is_SOMETHINGHERE_enabled` naming convention, and always normalise, and sanitize the variable before using it.
- The resource blocks always should point to locals-defined feature flags, and never to the direct input variable flag.
- Consider that sometimes the `var.is_enabled` and its corresponmding feature flag (in locals) `is_enabled` is calculated from a sum of other flags, or conditions. E.g.: `is_enabled = var.is_enabled && var.enable_encryption && var.somethingelse != null`.

## Styleguide: Tagging Strategy Rules

### Rule: Resource Tagging

- Implement a uniform tagging mechanism across all resources, considering always the particular requirements, constraints, and best practices of the resource type, and/or the providers it's using.
- Sanitize and normalize tags within `locals` before resource application

```hcl
locals {
    # Sanitize and normalize tags with strict validation
    common_tags = {
        Environment = var.environment == "production" ? "prod" : "dev"
        ManagedBy   = "Terraform"
        Project     = trimspace(var.project_name)
        CostCenter  = trimspace(var.cost_center)
    }

    # Merge the common tags with the module-specific tags
    tags = merge(local.common_tags, var.tags)
}

variable "tags" {
    type        = map(string)
    description = <<-DESC
    **MODULE-WIDE RESOURCE TAGGING STRATEGY**

    Provides a unified tagging mechanism for ALL resources created by the module:

    **TAGGING PURPOSE**:
    - Enforce consistent resource metadata
    - Enable advanced resource tracking and management
    - Support organizational governance and compliance

    **MODULE COMPOSITION**:
    - Applied uniformly across all module-generated resources
    - Supports complex tagging inheritance and extension
    - Enables fine-grained resource categorization

    **RECOMMENDED TAGGING STRATEGY**:
    - Include organizational context
    - Support multi-environment deployments
    - Enable cost allocation and tracking

    **USAGE EXAMPLE**:
    ```hcl
    module "example_module" {
      tags = {
        Environment = "production"
        Project     = "infrastructure-core"
        ManagedBy   = "Terraform"
      }
    }
    ```

    **ARCHITECTURAL GUIDELINES**:
    - Align with organizational tagging standards
    - Provide clear, meaningful tag semantics
    - Support dynamic tag generation and inheritance
    DESC
    default     = {}
}
```

