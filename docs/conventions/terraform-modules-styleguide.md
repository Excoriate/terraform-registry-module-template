# Terraform Module StyleGuide: Mandatory Design and Implementation Rules

## Core Ruleset: Specific Module Development Principles

### Rule: Module Design Philosophy
1. **Enforce Modular Boundaries**: Ensure each module has a singular, well-defined purpose
2. **Maximize Reusability**: Design modules to be adaptable across different infrastructure contexts
3. **Minimize External Dependencies**: Strictly limit and explicitly manage module dependencies
4. **Guarantee Module Isolation**: Create modules that can be used independently with minimal configuration
5. **Support Comprehensive Customization**: Provide extensive configuration options through well-defined variables

## Styleguide: Module Structure Rules

### Rule: Mandatory Module Directory Layout

**Requirement**: Strictly adhere to the following module structure:

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
└── examples/        # Usage examples
    ├── basic/       # Minimal configuration example
    └── complete/    # Full-featured configuration example
```

### Rule: Provider Configuration Guidelines
- If it's a child module, don't create the `providers.tf` file.
- If it's an example module in the `examples/` directory, create the `providers.tf` file, as these are considered root modules.

## Styleguide: Module-Specific Variable Management Rules

### Rule: Variable Definition Guidelines

**Mandatory Module-Specific Requirements**:
- Define all variables exclusively in `variables.tf`. Never create variables in the `main.tf` file.
- Create a `var.is_enabled` variable to enable/disable the entire module
- When dealing with cloud providers that support tagging (like AWS), always create a `tags` variable
- Provide comprehensive, verbose descriptions using EOT (End of Text) formatting
- Implement strict type constraints and validation blocks

#### Rule: Module-Specific Variable Examples

```hcl
variable "is_enabled" {
    description = <<-EOT
        Enforce global module resource creation toggle with comprehensive configuration control.

        Mandatory Purpose:
        - Provide centralized mechanism for dynamic module resource provisioning
        - Enable fine-grained module infrastructure management
        - Support complex deployment scenarios

        Behavioral Enforcement:
        - true: Provision ALL resources defined in the module
        - false: PREVENT all resource creation, enabling strict "dry run" mode

        Strategic Deployment Use Cases:
        - Environment-specific infrastructure deployment
        - Temporary module service suspension
        - Precise cost optimization and resource control
        - Conditional infrastructure management
    EOT
    type        = bool
    default     = true
}

variable "tags" {
    description = <<-EOT
        Enforce comprehensive tagging mechanism for uniform module resource management and governance.

        Mandatory Purpose:
        - Implement consistent module resource labeling
        - Enable advanced module resource tracking and cost allocation
        - Support organizational compliance and governance requirements

        Tagging Strategy Enforcement:
        - Keys: Mandate descriptive, standardized naming convention
        - Values: Provide specific context, metadata, or organizational information

        Required Organizational Tags:
        - Environment: Deployment stage (dev, staging, prod)
        - Project: Specific project or application name
        - ManagedBy: Infrastructure management method (Terraform)
        - CostCenter: Organizational financial tracking identifier
        - Owner: Team or department responsible for the module

        Validation Rules:
        - Enforce alphanumeric tag keys
        - Allow underscores and hyphens for enhanced readability
        - Prevent invalid or inconsistent tag configurations
    EOT
    type        = map(string)
    default     = {}
    validation {
        condition     = can([for k, v in var.tags : regex("^[a-zA-Z0-9_-]+$", k)])
        error_message = "Reject tag keys not meeting alphanumeric standards with optional underscores or hyphens."
    }
}
```

## Styleguide: Module-Specific Resource Configuration Rules

### Rule: Module Dynamic Resource Creation
**Requirement**: Utilize `for_each` and `locals` for managing complex, dynamic module resource generation:

```hcl
locals {
    # Enforce module resource creation based on strict conditions
    create_resources = var.is_enabled && length(var.instance_configurations) > 0
}

resource "aws_instance" "servers" {
    for_each = local.create_resources ? var.instance_configurations : {}

    # Strict module resource configuration enforcement
    instance_type = each.value.type
    tags = merge(var.tags, {
        Name = "server-${each.key}"
    })
}
```

## Styleguide: Module-Specific Output Design Rules

### Rule: Module Output Generation
**Mandatory Guidelines**:
- Provide comprehensive, meaningful module outputs
- Include critical module resource information
- Support complex output structures
- Ensure outputs provide clear module usage insights

```hcl
output "module_instance_details" {
    description = "Comprehensive module instance information with strict validation"
    value = {
        ids         = { for k, instance in aws_instance.servers : k => instance.id }
        private_ips = { for k, instance in aws_instance.servers : k => instance.private_ip }
        public_ips  = { for k, instance in aws_instance.servers : k => instance.public_ip }
    }
}
```

## Styleguide: Module-Specific Anti-Pattern Prevention Rules

### Prohibited Module Design Practices
- **Reject**: Creating modules with excessive, unrelated responsibilities
- **Prohibit**: Hardcoding environment-specific values within modules
- **Forbid**: Developing modules with overly complex, nested structures
- **Prevent**: Creating modules that are either too generic or too narrowly scoped

## Continuous Module Improvement Guidelines
- **Mandate**: Regular, comprehensive module design reviews
- **Require**: Continuous, constructive team feedback on module implementations
- **Enforce**: Staying current with Terraform module best practices
- **Establish**: A curated library of rigorously tested, highly reusable modules
