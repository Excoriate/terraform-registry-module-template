# Terraform Modules Directory 🏗️

## 📘 Module Design Philosophy

This directory contains Terraform modules that encapsulate infrastructure components with **strict design principles**:

- **Single Responsibility**: Each module solves a specific infrastructure challenge
- **Maximum Reusability**: Designed for adaptability across different environments
- **Minimal External Dependencies**: Carefully managed module interactions
- **Comprehensive Customization**: Extensive configuration through well-defined variables
- **Contract First Design**: Module interfaces (input variables and outputs) are paramount and designed before implementation. They define the module's expected behavior and interaction points.
- **Mandatory Tooling**: Every module MUST include `.terraform-docs.yml` for documentation and `.tflint.hcl` for linting.

## 📂 Enhanced Module Structure

A typical module within this directory follows this structure:
```text
/modules/[module-name]/
├── main.tf              # Primary resource definitions
├── locals.tf            # Complex computations and transformations
├── data.tf              # External data source retrieval (if needed)
├── variables.tf         # Input variable definitions
├── outputs.tf           # Module output definitions
├── versions.tf          # Provider and Terraform version constraints
├── README.md            # Comprehensive module documentation (auto-generated sections)
├── .terraform-docs.yml  # Terraform documentation generation config (mandatory)
├── .tflint.hcl          # TFLint configuration for static analysis (mandatory)
└── examples/            # Internal examples for demonstration/testing
    ├── basic/           # Minimal configuration example
    └── complete/        # Full-featured configuration example
```
**Note on `examples/` directory within a module**: This internal `examples/` directory is for self-contained examples or test fixtures that are part of the module's own codebase. This is distinct from the top-level `/examples` directory in the project, which contains standalone, runnable examples that consume these modules.
**Note on `providers.tf`**: This file is generally NOT included in reusable modules within the `modules/` directory as provider configurations are typically handled by the root module consuming these modules.

## 🛠 Documentation and Linting Tools

### Terraform Docs 📄
- **Purpose**: Automatic documentation generation for Terraform modules
- **Configuration**: `.terraform-docs.yml`
- **Key Features**:
  - Generates markdown documentation
  - Extracts variable and output descriptions
  - Customizable output format

**Documentation Generation Commands:**
```bash
# Generate module documentation
just tf-docs-generate

# Generate docs for a specific module
just tf-docs-generate MOD=default
```

### TFLint 🕵️
- **Purpose**: Static analysis tool for Terraform code
- **Configuration**: `.tflint.hcl`
- **Key Checks**:
  - Syntax validation
  - Best practice enforcement
  - Provider-specific rule checking

**Linting Commands:**
```bash
# Lint all modules
just tf-lint

# Lint a specific module
just tf-lint MOD=default
```

## 🎯 Module Creation Workflow

### Minimum Viable Product (MVP) Approach

- **Coverage Goal**: Design modules to work for at least 80% of use cases
- **Simplicity First**: Start with narrow, focused module scope
- **Avoid Complexity**:
  - No edge case handling in initial versions
  - Minimize conditional expressions
  - Expose only most commonly modified arguments

## 🔍 Key Module Conventions

### Documentation Best Practices
- **Comprehensive Descriptions**:
  - Detailed variable descriptions
  - Clear output explanations
  - Usage examples in README
- **Automatic Generation**:
  - Use Terraform Docs for consistent documentation
  - Keep documentation close to the code

### Linting Standards
- **Static Code Analysis**:
  - Enforce coding standards
  - Catch potential errors early
  - Maintain code quality across modules

## 🚀 Continuous Integration

**Automated Checks:**
```bash
# Run full module validation
just tf-ci-static MOD=default

# Includes:
# - Code formatting
# - Linting
# - Documentation generation
# - Terraform validation
```

## 💡 Module Design Principles

### Documentation and Linting Goals
- **Transparency**: Make module internals clear
- **Consistency**: Uniform documentation across modules
- **Quality**: Catch potential issues early
- **Usability**: Make modules easy to understand and use

## 📚 References

- [Terraform Docs](https://terraform-docs.io/)
- [TFLint](https://github.com/terraform-linters/tflint)
- [HashiCorp Module Creation Guide](https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation)

**Internal Style Guides (MUST READ for development):**
- **Modules**: [terraform-styleguide-modules.md](../../docs/terraform-styleguide/terraform-styleguide-modules.md)
- **Terraform Code (HCL)**: [terraform-styleguide-code.md](../../docs/terraform-styleguide/terraform-styleguide-code.md)
- **Examples (Top-Level)**: [terraform-styleguide-examples.md](../../docs/terraform-styleguide/terraform-styleguide-examples.md)
- **Terratest Tests**: [terraform-styleguide-terratest.md](../../docs/terraform-styleguide/terraform-styleguide-terratest.md)

**Note:** This guide represents our current best practices and evolves with the Terraform ecosystem.
