# Terraform Registry Module Template Repository Structure

## 🌳 Repository Overview

**Purpose**: This is a standardized template for Terraform modules, designed to provide a robust, well-structured, and maintainable framework for creating infrastructure-as-code modules.

## 📂 Top-Level Directory Structure

### `/modules`
**Rule**: Primary location for Terraform module implementations.
- Contains modular, reusable Terraform configurations
- Each subdirectory represents a distinct module (e.g., `default`)
- **Mandatory Files**:
```text
/modules/[module-name]/
├── main.tf              # Primary resource definitions
├── locals.tf            # Complex computations and transformations
├── data.tf              # External data source retrieval
├── variables.tf         # Input variable definitions
├── outputs.tf           # Module output definitions
├── versions.tf          # Provider and Terraform version constraints
├── providers.tf         # Optional provider configurations
├── README.md            # Comprehensive module documentation
├── .terraform-docs.yml  # Terraform documentation generation config
├── .tflint.hcl          # TFLint configuration for static analysis
```

### `/examples`
**Rule**: Showcase practical usage of modules.
- Provide real-world, working examples of module configurations
- Demonstrate various use cases and configuration patterns
- Structured with clear, progressive complexity (basic → advanced)

### `/tests`
**Rule**: Comprehensive testing infrastructure.
- Implements terratest for infrastructure testing
- Contains:
  - Unit tests
  - Integration tests
  - Validation scripts
- Uses Go for test implementation
- Ensures module reliability and correctness

### `/scripts`
**Rule**: Development and maintenance utilities.
- Contains helper scripts for:
  - Git hooks
  - Repository maintenance
  - Development workflow utilities
- Standardize development processes
- Automate repetitive tasks

### `/docs`
**Rule**: Project documentation.
- Store project-level documentation
- Include roadmaps, architectural decisions
- Provide context beyond code comments

## 🚨 Additional Repository Files

- `Justfile`: Task runner and command orchestration
- `flake.nix`: Nix package management configuration
- Various GitHub workflow files for CI/CD are in the `.github/workflows` directory
- Markdown files for project governance (README, CONTRIBUTING, etc.) are in the root directory. Some other are specific to particular directories (e.g. `tests/README.md`)
