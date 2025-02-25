# Terraform Module Examples StyleGuide: Mandatory Design and Implementation Rules

## Table of Contents

- [Terraform Module Examples StyleGuide: Mandatory Design and Implementation Rules](#terraform-module-examples-styleguide-mandatory-design-and-implementation-rules)
  - [Table of Contents](#table-of-contents)
  - [Purpose and Scope](#purpose-and-scope)
  - [Styleguide: Example Module Directory Structure](#styleguide-example-module-directory-structure)
    - [Rule: Core Directory Layout](#rule-core-directory-layout)
    - [Rule: General rules when implementing examples](#rule-general-rules-when-implementing-examples)
    - [Rule: Naming Conventions for examples](#rule-naming-conventions-for-examples)
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
