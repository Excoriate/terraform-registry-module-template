## Table of Contents

- [Terraform Module StyleGuide: Mandatory Design and Implementation Rules](#terraform-module-styleguide-mandatory-design-and-implementation-rules)
  - [Core Ruleset: Specific Module Development Principles](#core-ruleset-specific-module-development-principles)
    - [Rule: Module Design Philosophy](#rule-module-design-philosophy)
  - [Styleguide: Module Structure Rules](#styleguide-module-structure-rules)
    - [Rule: Mandatory Module Directory Layout](#rule-mandatory-module-directory-layout)
    - [Rule: Directories](#rule-directories)
    - [Rule: Provider Configuration Guidelines](#rule-provider-configuration-guidelines)
  - [Styleguide: Module Interfaces](#styleguide-module-interfaces)
    - [Definition and Components](#definition-and-components)
    - [Key Characteristics of a Well-Designed Module Interface](#key-characteristics-of-a-well-designed-module-interface)
    - [Interface Design Principles](#interface-design-principles)
  - [Styleguide: Variable Definition Guidelines](#styleguide-variable-definition-guidelines)
    - [Rule: Variable Definition Requirements](#rule-variable-definition-requirements)
    - [Rule: Variable Definition Guidelines](#rule-variable-definition-guidelines)
    - [Rule: Variable Description, and Self-Documentation](#rule-variable-description-and-self-documentation)
  - [Styleguide: Configuration Resources](#styleguide-configuration-resources)
    - [Rule: Resource Naming Conventions](#rule-resource-naming-conventions)
    - [Rule: Module Tagging Requirements](#rule-module-tagging-requirements)
  - [Styleguide: Module-Specific Resource Configuration Rules](#styleguide-module-specific-resource-configuration-rules)
    - [Rule: Module Dynamic Resource Creation](#rule-module-dynamic-resource-creation)
  - [Styleguide: Module-Specific Output Design Rules](#styleguide-module-specific-output-design-rules)
    - [Rule: Module Output Generation](#rule-module-output-generation)
  - [Styleguide: Module-Specific Anti-Pattern Prevention Rules](#styleguide-module-specific-anti-pattern-prevention-rules)
    - [Prohibited Module Design Practices](#prohibited-module-design-practices)
  - [Continuous Module Improvement Guidelines](#continuous-module-improvement-guidelines)
  - [Styleguide: Module Documentation Configuration Rules](#styleguide-module-documentation-configuration-rules)
    - [Rule: Terraform-Docs Configuration](#rule-terraform-docs-configuration)
    - [Rule: Terraform-Docs Configuration Example](#rule-terraform-docs-configuration-example)
  - [Styleguide: Module Linting Configuration Rules](#styleguide-module-linting-configuration-rules)
    - [Rule: TFLint Configuration](#rule-tflint-configuration)
  - [Core Ruleset: Creating a new module from scratch](#core-ruleset-creating-a-new-module-from-scratch)
    - [Rule: Starting and creating the boilerplate code](#rule-starting-and-creating-the-boilerplate-code)
    - [Rule: Feedback loop](#rule-feedback-loop)
  - [Styleguide: Reliability and Tests](#styleguide-reliability-and-tests)
    - [Rules: Always, tests, and examples](#rules-always-tests-and-examples)

---

# Terraform Module StyleGuide: Mandatory Design and Implementation Rules

## Core Ruleset: Specific Module Development Principles

### Rule: Module Design Philosophy

- Each module MUST have a singular, well-defined purpose. A module is a composition of resources, and configurations that represent an architectural pattern.
- Design modules to be adaptable across different infrastructure contexts
- START with simple implementations. ADD complexity only when necessary and well-justified
- STRICTLY limit and explicitly manage module dependencies. Always check the `versions.tf` if the module is a root module and it's caling another module, to adhere to its version requirements.
- STRICTLY use the latest stable Terraform version, and the latest version of the used providers on this module.
- **Guarantee Module Isolation**: CREATE modules that can be used independently, and composable with other modules incrementally.
- CONTRACT FIRTS! Never break the 'contract' of a module. The contract are its interfaces, and the behaviors it implements (interfaces are the input variables, and its outputs are the resources it creates). When designing a module, the first think to do is to define the contract, and then implement it.
- The documentation of the module is generated through terraform-docs, from the `.terraform-docs.yml` file. This file is mandatory.
- The static analysis of the module is done through TFLint, and the `.tflint.hcl` file is mandatory.
- NO esoteric or complex configurations are allowed in the module. Simplicity is the key.

---

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
├── .terraform-docs.yml # Documentation generation configuration
├── .tflint.hcl      # Terraform linting rules
└── examples/        # Usage examples
    ├── basic/       # Minimal configuration example
    ├── complete/    # Full-featured configuration example
    └── additional/  # Additional examples may be added as needed
```

- Some modules will require specialised files, such as `iam_roles.tf` for IAM role management, or `data.tf` for external data source retrieval. This is only permitted for modules which provide a lot of resources, so grouping them into contextual files (per resource type, or platform ocntext) is encouraged, keeping the `main.tf` file clean and readable, and only concerned with the core resource definitions. This only is applicable if the amount of resources is high, and there are several resources that can be grouped into a contextual file.
- Don't create the `providers.tf` file. It's only meant for root modules (E.g.: other modules calling this one, or an example module created in the `examples/MYMODULE/basic` directory to test this module).
- Always include a `.terraform-docs.yml` file in every module root directory, to favour automated documentation generation using the existing Justfile, or through CI.
- Always include a `.tflint.hcl` file in every module root directory, to favour automated linting using the existing Justfile, or through CI.

### Rule: Directories

- USE always the `modules/[module-name]/` directory structure for all modules to create.
- USE the `examples/[module-name]/` directory structure for all examples to create. On each `examples/[module-name]/` directory, create a `basic/` directory to contain the basic example, and an `complete/` directory to contain the complete example. More examples may be added as needed for particular and supported use cases.
- USE the `tests/modules/[module-name]/unit` directory structure for all unit tests to create, and the `tests/modules/[module-name]/integration` directory structure for all integration tests to create (the latter are rarely needed).

The tests standard structure is described as follows:

```text
tests/
├── README.md               # Testing documentation
├── go.mod                  # Go module dependencies
├── go.sum                  # Dependency lockfile
├── pkg/                    # Shared testing utilities
│   └── repo/               # Repository path utilities
│       └── finder.go       # Path resolution functions
│   └── helper/             # Helper utilities
│       └── resources.go    # Resources utilities
│       └── terraform.go    # Terraform utilities
└── modules/                # Module-specific test suites
    └── <module_name>/      # Tests for specific module
        ├── target/         # Use-case specific test suite
        │   ├── basic/      # Basic use-case configuration
        │   │   └── main.tf # Terraform configuration for basic use-case
        │   ├── specific_use_case/  # Specific use-case depending on the module's configuration, and capabilities
        │   │   └── main.tf # Terraform configuration for specific use-case
        │   └── disabled_module/  # Specific use-case for disabled configuration
        │       └── main.tf # Terraform configuration for disabled configuration use-case
        ├── unit/           # Unit test suite
        │   └── target_specific_use_case_ro_unit_test.go          # Read-only unit test for specific configuration
        │   └── target_specific_use_case_integration_test.go      # End-to-end integration test for specific use-case
        └── examples/    # Examples test suite, with e2e tests
            ├── example_complete_integration_test.go                # End-to-end integration test for complete example
            ├── example_basic_ro_test.go                            # Read-only unit test for basic example
            └── example_disabled_configuration_integration_test.go  # End-to-end integration test for disabled configuration example
```

For more details, and a complete specification about how to write Terratest tests on this repo, and its modules, please refer to [Terratest Guideline](terraform-styleguide-terratest.md)

The example standard structure is described as follows:

```text
examples
├── README.md
├── README.md
└── default
    └── basic
        ├── README.md
        ├── fixtures
        │   └── fixtures.tfvars
        ├── main.tf
        ├── outputs.tf
        ├── providers.tf
        ├── variables.tf
        └── versions.tf
        ├── Makefile
        ├── .terraform-docs.yml
        └── .tflint.hcl
    └── complete
        └── ...

```

### Rule: Provider Configuration Guidelines

- You MUST not create the `providers.tf` file when the module isn't a root module.
- If it's an example module in the `examples/` directory, create the `providers.tf` file, as these are considered root modules. Ensure that you're aligned with the `versions.tf` file of the called module.
- For root modules, you MUST create the `providers.tf` file, and ensure that it's aligned with the `versions.tf` file of the called module.

---

## Styleguide: Module Interfaces

### Definition and Components

A module interface in Terraform is the contract that defines how a module interacts with the outside world. It consists of three primary components:

1. **Inputs (Variables)**: The parameters that can be passed into the module to configure its behavior.
2. **Outputs**: The values that the module returns after creating or managing resources.

### Key Characteristics of a Well-Designed Module Interface

- **Clarity**: Inputs and outputs should have clear, comprehensive descriptions that provide clear indications what to expect from the module, and what is suitable to use the module's outputs for composition.
- **Type Safety**: Strong typing for all inputs to prevent unexpected behaviors and ensure that the module's behavior is predictable and consistent.
- **Validation**: Built-in validation rules to ensure input integrity and provide clear error messages for invalid inputs. Never vague, or ambiguous error messages.
- **Flexibility**: Provide sensible defaults while allowing extensive customization to meet specific use cases.
- **Predictability**: Consistent behavior across different input configurations to ensure that the module's behavior is predictable and consistent.

### Interface Design Principles

1. **Minimize Surprise**
   - Inputs should have intuitive names, readables, and meaningful defaults that are documented in the variable descriptions.
   - Outputs should provide meaningful, actionable information that is documented in the output descriptions.
   - Outputs are explicit. They say what they provide, what they don't, how to compose the module through them, and their 'shape'.
   - Avoid complex, nested input structures when possible

2. **Comprehensive Documentation**
   - Every input and output should have a detailed description
   - Explain the purpose, constraints, and potential impacts of each interface element

3. **Validation and Constraints**
   - Use Terraform's validation blocks to enforce input rules
   - Provide clear error messages for invalid inputs
   - Implement type constraints to prevent runtime errors

---

## Styleguide: Variable Definition Guidelines

### Rule: Variable Definition Requirements

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

## Styleguide: Configuration Resources

### Rule: Resource Naming Conventions

**Mandatory Requirements**:

1. **Resource Names**
   - USE `this` for singleton resources
   - IMPLEMENT clear, descriptive names
   - FOLLOW consistent naming patterns

2. **Naming Structure**
   - USE lowercase with underscores
   - INCLUDE resource type in name
   - MAINTAIN consistency across module

**Example Resource Names**:
```hcl
# Compliant Names
resource "aws_kms_key" "this" {                    # Singleton resource
    # ... configuration ...
}

resource "aws_cloudwatch_log_group" "application" { # Specific purpose
    # ... configuration ...
}

# Non-Compliant Names (Avoid)
resource "aws_kms_key" "key1" { }                  # Unclear purpose
resource "aws_cloudwatch_log_group" "logs" { }     # Too generic
```

3. **Feature Flag Implementation**
   - COMPUTE flags in `locals.tf`
   - KEEP resource blocks clean
   - USE consistent flag naming

```hcl
locals {
    # Feature flags
    is_encryption_enabled = var.is_enabled && var.enable_encryption
    is_logging_enabled   = var.is_enabled && var.enable_logging

    # Resource configurations
    kms_key_config = local.is_encryption_enabled ? {
        deletion_window_in_days = 7
        enable_key_rotation    = true
    } : null
}

resource "aws_kms_key" "this" {
    count = local.is_encryption_enabled ? 1 : 0

    deletion_window_in_days = local.kms_key_config.deletion_window_in_days
    enable_key_rotation    = local.kms_key_config.enable_key_rotation
}
```

### Rule: Module Tagging Requirements

**Mandatory Requirements**:

1. **Tag Variable Definition**
   - IMPLEMENT a `tags` variable in every module
   - USE `map(string)` type
   - PROVIDE clear documentation of required tags

2. **Tag Processing**
   - NORMALIZE tags in `locals.tf`
   - MERGE common and resource-specific tags
   - VALIDATE tag format and values

3. **Tag Application**
   - APPLY tags consistently across all resources
   - RESPECT provider-specific tagging limitations
   - DOCUMENT any resource-specific tag requirements

**Example Implementation**:

```hcl
locals {
    # Common tags applied to all resources
    common_tags = {
        Environment = var.environment
        ManagedBy  = "Terraform"
        Module     = "example-module"
    }

    # Merge and normalize all tags
    tags = merge(
        local.common_tags,
        var.tags,
        {
            Name = coalesce(var.name_override, "example-resource")
        }
    )
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

    **REQUIRED TAGS**:
    - Environment: Deployment environment (e.g., prod, staging, dev)
    - Project: Project or application name
    - Owner: Team or individual responsible
    - CostCenter: Financial tracking identifier

    **USAGE EXAMPLE**:
    ```hcl
    module "example" {
      tags = {
        Environment = "production"
        Project     = "core-infrastructure"
        Owner       = "platform-team"
        CostCenter  = "platform-123"
      }
    }
    ```
    DESC
    default     = {}

    validation {
        condition     = can([for k, v in var.tags : regex("^[a-zA-Z0-9_-]+$", k)])
        error_message = "Tag keys must be alphanumeric with optional underscores or hyphens."
    }
}

# Example resource with tags
resource "aws_kms_key" "this" {
    count = local.is_encryption_enabled ? 1 : 0

    deletion_window_in_days = local.kms_key_config.deletion_window_in_days
    enable_key_rotation    = local.kms_key_config.enable_key_rotation
    tags = local.tags
}
```

---

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

- Keep feature flags small and specific in the `locals.tf` file to maintain module clarity. For example, use `is_kms_key_enabled`, `is_log_group_enabled`, and `is_s3_bucket_enabled` as individual flags. Only combine them when multiple resources require conditional creation based on all flags being `true`.
- Feature flags for specific resources are only needed when the module provide an incremental architecture, or a composable-architecture way of managing resources. For example, if you have a module that creates a VPC, and you want to create a subnet in that VPC, you can use a feature flag to decide whether to create the subnet or not. In this case, the feature flag should be named `is_subnet_enabled` and the subnet should be created only if the flag is set to `true`.

**Important Note**:

- Do not overcomplicate the `for_each` in the resource that it is used. Encapsulate any ternary logic, or multiple conditions for that for_each in a `locals.tf` file, and use the `local.create_resources` variable to control the creation of the resources, keeping the resource clean and readable.

---

## Styleguide: Module-Specific Output Design Rules

### Rule: Module Output Generation

**Mandatory Guidelines**:

- Always provide comprehensive and meaningful module outputs.
- Ensure outputs account for resources that may be conditionally or incrementally created. Handle these cases gracefully and include clear usage instructions.
- Include essential resource information and provide detailed descriptions, especially if outputs will be used by other modules that require specific parameters or structures.
- Support complex output structures to enhance usability.
- Outputs must offer clear insights into module usage.

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

---

## Styleguide: Module-Specific Anti-Pattern Prevention Rules

### Prohibited Module Design Practices

- **Reject**: Creating modules with excessive, unrelated responsibilities
- **Prohibit**: Hardcoding environment-specific values within modules
- **Forbid**: Developing modules with overly complex, nested structures
- **Prevent**: Creating modules that are either too generic or too narrowly scoped

---

## Continuous Module Improvement Guidelines

- **Mandate**: Regular, comprehensive module design reviews
- **Require**: Continuous, constructive team feedback on module implementations
- **Enforce**: Staying current with Terraform module best practices
- **Establish**: A curated library of rigorously tested, highly reusable modules

---

## Styleguide: Module Documentation Configuration Rules

### Rule: Terraform-Docs Configuration

- Include a `.terraform-docs.yml` file in every module root directory. ALWAYS, no exceptions.
- Ensure consistent documentation format across all modules
- Use the first part of the template file (`## Overview`, and its child sections: `### Key Features`, `#Usage Guidelines`) as the module introduction, indicating clearly its capabilities, features, purpose, and usage. This is the part that's customized for each module, and it's not automatically generated. Make it comprehensive and informative.
- Follow this standardized configuration:

### Rule: Terraform-Docs Configuration Example

```yaml
---
formatter: markdown table

sections:
  hide: []
  show:
    - inputs
    - outputs
    - resources

content: |-
  # Terraform Module: [Module Name]

  ## Overview
  > **Note:** This module provides [brief description of module purpose].

  ### 🔑 Key Features
  - **[Feature 1]**: [Brief description]
  - **[Feature 2]**: [Brief description]
  - **[Feature 3]**: [Brief description]

  ### 📋 Usage Guidelines
  1. [Step 1]
  2. [Step 2]
  3. [Step 3]

  {{ .Header }}

  ## Variables

  {{ .Inputs }}

  ## Outputs

  {{ .Outputs }}

  ## Resources

  {{ .Resources }}

output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

settings:
  anchor: true
  color: true
  description: true
  escape: true
  header: true
  html: true
  indent: 2
  required: true
  sensitive: true
  type: true
```

---

## Styleguide: Module Linting Configuration Rules

### Rule: TFLint Configuration

- Include a `.tflint.hcl` file in every module root directory, always. No exceptions.
- Enforce code quality standards
- Use the following default `.tflint.hcl` configuration:

```hcl
config {
  force = false
}

plugin "aws" {
  enabled = true
  version = "0.38.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Mandatory Rules - Always Enabled
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_lookup" {
  enabled = true
}

rule "terraform_empty_list_equality" {
  enabled = true
}

rule "terraform_map_duplicate_keys" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

# Documentation Quality Rules
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

# Code Quality Rules
rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}
```

## Core Ruleset: Creating a new module from scratch

### Rule: Starting and creating the boilerplate code

- ALWAYS create the module's directory structure and files following the [recommended directory structure](#recommended-directory-structure) and [recommended file names](#recommended-file-names).
- ALWAYS create the examples directory and files following the [recommended directory structure](#recommended-directory-structure) and [recommended file names](#recommended-file-names).
- ALWAYS create the tests directory and files following the [recommended directory structure](#recommended-directory-structure) and [recommended file names](#recommended-file-names).

### Rule: Feedback loop

- ALWAYS use the `just` command from the [Justfile](Justfile) to automate the module development workflow, and to ensure consistent formatting, linting, and project management. These commands are handy:
  - `just tf-validate "<MODULENAME>"` - Validate the module's Terraform code in the modules directory. E.g.: `just tf-validate acme` where the module is located in `modules/acme`.
  - `just tf-ci-static "<MODULENAME>"` - Run the static code analysis checks in the modules directory. E.g.: `just tf-ci-static acme` where the module is located in `modules/acme`.
  - Running the examples is always a good idea when developing a module. Use the `just tf-exec "examples/<MODULENAME>/<EXAMPLENAME>" 'init'` command to initialize the example module, and the `just tf-exec "examples/<MODULENAME>/<EXAMPLENAME>" 'plan'` command to run a Terraform plan.

## Styleguide: Reliability and Tests

### Rules: Always, tests, and examples

- EVERY module in the `modules/[module-name]/` directory MUST have a corresponding test in the `tests/modules/[module-name]/unit/` directory, and another one in the `tests/modules/[module-name]/examples/` directory. ALWAYS follow these [guildelines](terraform-styleguide-terratest.md) for the tests.

- EVERY module in the `modules/[module-name]/` directory MUST at least a `basic` example in the `examples/[module-name]/basic/` directory, as the starting point. For more information about the guidelines for writing examples, see the [examples section](terraform-styleguide-examples.md).
