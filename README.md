<h1 align="center">
  <img alt="logo" src="https://forum.huawei.com/enterprise/en/data/attachment/forum/202204/21/120858nak5g1epkzwq5gcs.png" width="224px"/><br/>

[![🧼 Pre-commit Hooks](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/pre-commit.yml) [![📚 Terraform Modules CI](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/tf-modules-ci.yaml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/tf-modules-ci.yaml) [![🦫 Go Code Quality Checks](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/go-linter.yaml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/go-linter.yaml)
---

## Terraform Registry Module Template

Add the description of your module here.

> [!TIP]
> It is essential to provide a clear and comprehensive description of your module. A well-written description helps users understand the purpose and functionality of your module. For more information on how to write effective module descriptions, please refer to the [Terraform Registry documentation](https://registry.terraform.io/).

### Features

This module provides:

> [!TIP]
> When describing the features of your module, focus on clarity and brevity. Highlight the key functionalities and benefits without unnecessary jargon. This helps users quickly grasp what your module offers and how it can be beneficial for their projects.

- 🚀 Add feature here
- 🚀 Add feature here
- 🚀 Add feature here

### Usage

## Development Workflow

This project uses [Just](https://github.com/casey/just) as a command runner for common development tasks. Just provides a convenient way to run project-specific commands and automate workflows.

### Prerequisites

- **Just**: Install the Just command runner
  ```bash
  # macOS
  brew install just

  # Linux
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin

  # Windows
  scoop install just
  ```

- **Nix** (Optional): For reproducible development environment
  ```bash
  # Install Nix
  curl -L https://nixos.org/nix/install | sh

  # Enter development shell
  nix develop
  ```

### Available Commands

Run `just` without arguments to see all available commands:

```bash
just
```

#### Common Development Tasks

**Terraform Operations:**
```bash
# Validate Terraform modules
just tf-validate "module-name"

# Run static analysis on modules
just tf-ci-static "module-name"

# Execute Terraform commands in specific directories
just tf-exec "examples/module-name/basic" "init"
just tf-exec "examples/module-name/basic" "plan"
```

**Testing:**
```bash
# Run unit tests
just tf-test-unit

# Run example tests
just tf-test-examples

# Run tests with specific parameters
just tf-test-unit "module-name" "readonly,unit" "unit" "false" "5m"
```

**Code Quality:**
```bash
# Run pre-commit hooks
just hooks-run

# Format code
just fmt

# Run linting
just lint
```

**Documentation:**
```bash
# Generate module documentation
just docs-generate

# Update README files
just docs-update
```

### Quick Start

1. **Initialize the development environment:**
   ```bash
   just init
   ```

2. **Validate your changes:**
   ```bash
   just validate
   ```

3. **Run tests:**
   ```bash
   just test
   ```

4. **Format and lint code:**
   ```bash
   just fmt
   just lint
   ```

For detailed information about available commands and their parameters, run:
```bash
just --list
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Documentation References

- **Tests** (`/tests`):
  - [Testing Overview and Guidelines](/tests/README.md)
  - Comprehensive infrastructure testing using Terratest
  - Includes unit, integration, and validation tests

- **Scripts** (`/scripts`):
  - [Development Utilities and Workflow](/scripts/README.md)
  - Helper scripts for Git hooks, repository maintenance
  - Standardized development process automation

- **Modules** (`/modules`):
  - [Module Development Guidelines](/modules/README.md)
  - [Terraform Modules StyleGuide](/docs/terraform-styleguide/terraform-styleguide-modules.md)
  - Reusable, well-structured Terraform module implementations

- **Examples** (`/examples`):
  - [Module Usage Examples](/examples/README.md)
  - Practical configurations demonstrating module usage
  - Progressive complexity from basic to advanced scenarios

- **Docs** (`/docs`):
  - [Developer Tools Guide](/docs/guides/development-tools-guide.md)
  - Terraform StyleGuide:
    - [Code Guidelines](/docs/terraform-styleguide/terraform-styleguide-code.md)
    - [Modules Guidelines](/docs/terraform-styleguide/terraform-styleguide-modules.md)
    - [Examples Guidelines](/docs/terraform-styleguide/terraform-styleguide-examples.md)
    - [Terratest Guidelines](/docs/terraform-styleguide/terraform-styleguide-terratest.md)
  - [Project Roadmap](/docs/ROADMAP.md)
  - Comprehensive project documentation and future plans

**📘 Additional Resources:**
- [Contribution Guidelines](CONTRIBUTING.md)
- [Terraform Registry Module Best Practices](/docs/terraform-styleguide/terraform-styleguide-modules.md)
