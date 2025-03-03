# Terraform Module Examples StyleGuide: Mandatory Design and Implementation Rules

## Table of Contents

- [Terraform Module Examples StyleGuide: Mandatory Design and Implementation Rules](#terraform-module-examples-styleguide-mandatory-design-and-implementation-rules)
  - [Table of Contents](#table-of-contents)
  - [Purpose and Scope](#purpose-and-scope)
  - [Styleguide: Example Module Directory Structure](#styleguide-example-module-directory-structure)
    - [Rule: Core Directory Layout](#rule-core-directory-layout)
    - [Rule: General rules when implementing examples](#rule-general-rules-when-implementing-examples)
    - [Rule: Naming Conventions for examples](#rule-naming-conventions-for-examples)
    - [Rule: Makefile Implementation](#rule-makefile-implementation)
    - [Rule: Basic Example](#rule-basic-example)
    - [Rule: Complete Example](#rule-complete-example)

## Purpose and Scope

This document provides comprehensive guidelines for creating example modules in Terraform registry modules, ensuring consistent, high-quality, and informative implementation examples.

## Styleguide: Example Module Directory Structure

### Rule: Core Directory Layout

- ALWAYS follow this structure when creating example implementations of modules located in the `modules/` directory.

```text
/examples/[module-name]/
├── basic/ # by default is basic, but can me complete, or my_use_case
│   ├── main.tf            # Minimal, foundational module usage
│   ├── variables.tf       # Example input variables
│   ├── outputs.tf         # Example outputs
│   ├── versions.tf        # Provider and Terraform version constraints
│   ├── providers.tf       # Provider configurations
│   ├── Makefile           # Commands for quickly testing different scenarios
│   ├── .terraform-docs.yml # Documentation generation configuration
│   ├── .tflint.hcl        # Terraform linting rules
│   └── fixtures/
│       └── fixtures-disabled.tfvars  # Fixture for testing with the feature flag disabled
│       └── fixtures-default.tfvars  # Default fixture with no predefined variable configurations
├── complete/              # Comprehensive, feature-rich example
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── providers.tf
│   ├── Makefile           # Commands for quickly testing different scenarios
│   ├── .terraform-docs.yml # Documentation generation configuration
│   ├── .tflint.hcl        # Terraform linting rules
│   └── fixtures/
│       └── fixtures-disabled.tfvars  # Fixture for testing with the feature flag disabled
│       └── fixtures-default.tfvars  # Default fixture with no predefined variable configurations
└── [specific-use-case]/   # Optional specialized examples
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── providers.tf
    ├── Makefile           # Commands for quickly testing different scenarios
│   ├── .terraform-docs.yml # Documentation generation configuration
│   ├── .tflint.hcl        # Terraform linting rules
    └── fixtures/
│       └── fixtures-disabled.tfvars  # Fixture for testing with the feature flag disabled
│       └── fixtures-default.tfvars  # Default fixture with no predefined variable configurations
```

- ALWAYS start with the `module/[module-name]/basic/` example, and add more examples as needed. When completing a module, and all the tests in the `tests/modules/[module-name]/unit` directory pass, you can consider completing the `complete/` example.
- The modules in the `examples/[module-name]/` directory are meant to be used as a starting point for new users, and as a reference for module developers. They are root modules, and they should be simple enough to demonstrate the core functionality of the module, but not too complex to avoid overwhelming new users with too much information.
- ALWAYS, the module's name in the `examples/[module-name]/` directory should match the name of the module in the `modules/[module-name]/` directory.

### Rule: General rules when implementing examples

- Use default or minimal input variables, but always looking at the module's `variables.tf` file to understand the full set of variables.
- ALWAYS replicate the `outputs.tf` file in the example directory, and use the `terraform output` command to validate the outputs.
- ALWAYS ensure you're following the version constraints in the `versions.tf` file of the called module in the `modules/[module-name]/versions.tf` example.
- ALWAYS create a fixture in the `fixtures/` directory of the example module implementation `examples/[module-name]/[example-name]/fixtures/` directory called `fixture-disabled.tfvars` with the `is_enabled = false` variable set, to always have a fixture to test the module when the feauture flag is disabled.
- ALWAYS create a fixture in the `fixtures/` directory of the example module implementation `examples/[module-name]/[example-name]/fixtures/` directory called `default.tfvars` empty, to always have a fixture to test the module when the feauture flag is enabled, and the default values are set for the module.
- ALWAYS create a fixture in the `fixtures/` directory of the example module implementation `examples/[module-name]/[example-name]/fixtures/` directory called `disabled.tfvars` with the `is_enabled = false` variable set, to always have a fixture to test the module when the feauture flag is disabled.
- ALWAYS use meaningful, and realistic values when setting the values for the input variables in the `main.tf` of the `examples/[module-name]/[example-name]/` module, BUT CAREFULLY VALIDATE that you're not creating a dependency that's overcomplicating the module's behavior (E.g.: creating other resources to get values to fill the input variables, making the example implementation flaky, and prone to failure).

### Rule: Naming Conventions for examples

- ALWAYS call the module in the `main.tf` file of the example implementation `examples/[module-name]/[example-name]/main.tf` `this`.

```hcl
module "this" {
  source     = "../../../modules/mymodule"
  is_enabled = var.is_enabled # This is set in the fixtures/default.tfvars file

  # Other module configurations, and input variables

  tags = {
    environment = "development"
    project     = "terraform-module-template"
    managed-by  = "terraform"
  }
}
```

### Rule: Makefile Implementation

**Purpose**: Provide standardized, consistent commands for quickly testing different scenarios using the example's fixtures.

- ALWAYS include a Makefile in each example directory with standardized commands for testing the module.
- ALWAYS structure the Makefile with clear sections for init, plan, apply, destroy, cycle, and utility commands.
- ALWAYS include commands for each fixture variant in the example's fixtures directory.
- ALWAYS include a comprehensive help command as the default target.
- ALWAYS define commands that follow the pattern `[action]-[fixture]` (e.g., `plan-default`, `apply-disabled`, etc.).

The Makefile should follow this structure:

```makefile
# Makefile for [MODULE NAME] - [EXAMPLE TYPE] Example
# This file provides quick commands for testing the module

# Default AWS region if not specified
AWS_REGION ?= us-west-2

.PHONY: help init \
        plan-default plan-disabled [additional-plan-commands] \
        apply-default apply-disabled [additional-apply-commands] \
        destroy-default destroy-disabled [additional-destroy-commands] \
        cycle-default cycle-disabled [additional-cycle-commands] \
        clean

# Default target when just running 'make'
help:
	@echo "[MODULE NAME] - [EXAMPLE TYPE] Example"
	@echo ""
	@echo "Available commands:"
	@echo "  make init                 - Initialize Terraform"
	@echo ""
	@echo "  Plan commands (terraform plan):"
	@echo "  make plan-default         - Plan with default configuration"
	@echo "  make plan-disabled        - Plan with module entirely disabled"
	# List additional plan commands here
	@echo ""
	@echo "  Apply commands (terraform apply):"
	@echo "  make apply-default        - Apply with default configuration"
	@echo "  make apply-disabled       - Apply with module entirely disabled"
	# List additional apply commands here
	@echo ""
	@echo "  Destroy commands (terraform destroy):"
	@echo "  make destroy-default      - Destroy resources with default configuration"
	@echo "  make destroy-disabled     - Destroy resources with module entirely disabled"
	# List additional destroy commands here
	@echo ""
	@echo "  Complete cycle commands (plan, apply, and destroy):"
	@echo "  make cycle-default        - Run full cycle with default configuration"
	@echo "  make cycle-disabled       - Run full cycle with module entirely disabled"
	# List additional cycle commands here
	@echo ""
	@echo "  Utility commands:"
	@echo "  make clean                - Remove .terraform directory and other Terraform files"
	@echo ""
	@echo "Environment variables:"
	@echo "  AWS_REGION                - AWS region to deploy resources (default: us-west-2)"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Plan commands
plan-default: init
	@echo "Planning with default fixture..."
	terraform plan -var-file=fixtures/default.tfvars

plan-disabled: init
	@echo "Planning with disabled fixture (module entirely disabled)..."
	terraform plan -var-file=fixtures/disabled.tfvars

# Additional plan commands for specific fixtures
# plan-[feature]-disabled: init
#	@echo "Planning with [feature] component disabled..."
#	terraform plan -var-file=fixtures/[feature]-disabled.tfvars

# Apply commands
apply-default: init
	@echo "Applying with default fixture..."
	terraform apply -var-file=fixtures/default.tfvars -auto-approve

apply-disabled: init
	@echo "Applying with disabled fixture (module entirely disabled)..."
	terraform apply -var-file=fixtures/disabled.tfvars -auto-approve

# Additional apply commands for specific fixtures
# apply-[feature]-disabled: init
#	@echo "Applying with [feature] component disabled..."
#	terraform apply -var-file=fixtures/[feature]-disabled.tfvars -auto-approve

# Destroy commands
destroy-default: init
	@echo "Destroying resources with default fixture..."
	terraform destroy -var-file=fixtures/default.tfvars -auto-approve

destroy-disabled: init
	@echo "Destroying resources with disabled fixture (module entirely disabled)..."
	terraform destroy -var-file=fixtures/disabled.tfvars -auto-approve

# Additional destroy commands for specific fixtures
# destroy-[feature]-disabled: init
#	@echo "Destroying resources with [feature] component disabled..."
#	terraform destroy -var-file=fixtures/[feature]-disabled.tfvars -auto-approve

# Run full cycle commands
cycle-default: plan-default apply-default destroy-default
	@echo "Completed full cycle with default fixture"

cycle-disabled: plan-disabled apply-disabled destroy-disabled
	@echo "Completed full cycle with disabled fixture (module entirely disabled)"

# Additional cycle commands for specific fixtures
# cycle-[feature]-disabled: plan-[feature]-disabled apply-[feature]-disabled destroy-[feature]-disabled
#	@echo "Completed full cycle with [feature] component disabled"

# Clean up Terraform files
clean:
	@echo "Cleaning up Terraform files..."
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup .terraform.tfstate.lock.info
	@echo "Cleanup complete"
```

For modules with component-specific feature flags like the foundation module example, include additional commands for each feature flag variation:

- Commands for components that can be individually disabled (e.g., `plan-kms-disabled`, `apply-s3-disabled`)
- Full cycle commands for each component variation (e.g., `cycle-logs-disabled`)

These fixtures should match the module's capabilities and feature flags, and should always include at minimum:
- `default.tfvars` - Default configuration with all features enabled
- `disabled.tfvars` - Configuration with the entire module disabled (`is_enabled = false`)
- Additional fixtures for each significant configuration variation

The Makefile provides a consistent interface for users to experiment with different module configurations, making it easier to understand the module's behavior under various scenarios without having to remember complex Terraform command-line options.

### Rule: Basic Example

*Purpose**: Demonstrate minimal, essential module configuration

- Keep it simple, and to demostrate the core functionality of the module.
- Use different fixtures in the `fixtures/` directory of the example module implementation `examples/[module-name]/[example-name]/fixtures/` directory to demonstrate different configuration scenarios that can be categorized as "basic"

### Rule: Complete Example

*Purpose**: Illustrate comprehensive module capabilities, with almost if not all the features of the module.

- Cover 80-90% of potential module use cases
- Demonstrate advanced variable interactions
- Demonstrate advanced configuration options
- Show multiple resource configurations
- Highlight complex use cases
