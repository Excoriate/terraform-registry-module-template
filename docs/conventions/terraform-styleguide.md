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
- Provide comprehensive descriptions with examples and registry references
- Implement strict type constraints, explicitly avoiding `any` type
- Apply validation blocks for enhanced input control

#### Rule: Variable Definition Example
```hcl
variable "instance_type" {
    description = <<-EOT
        Strictly defines the EC2 instance type for server provisioning with comprehensive configuration controls.

        Mandatory Considerations:
        - Directly impacts application performance and infrastructure cost
        - Enforce selection from predefined instance families

        Allowed Instance Families:
        - t3: Burstable, cost-effective for variable workloads
        - m5: General-purpose, balanced compute and memory
        - c5: Compute-optimized for high-performance computing

        Deployment Type Recommendations:
        - Development: Mandate smaller, cost-effective instances (t3.micro)
        - Staging: Require medium-sized instances with balanced resources (m5.large)
        - Production: Select instances precisely matching workload requirements

        Validation Enforcement:
        - Prevent selection of unsupported or incompatible instance types
    EOT
    type        = string
    validation {
        condition     = can(regex("^(t3|m5|c5)\\.", var.instance_type))
        error_message = "Reject instance types not from t3, m5, or c5 series. Ensure strict workload compatibility."
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
**Requirement**: Utilize `for_each` and `locals` for managing complex, dynamic resource generation:

```hcl
locals {
    # Enforce resource creation based on environment
    create_resources = var.environment != "prod"
}

resource "aws_instance" "development_servers" {
    for_each = local.create_resources ? var.server_configs : {}
    # Strict resource configuration
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
