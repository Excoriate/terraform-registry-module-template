<h1 align="center">
  <img alt="logo" src="https://forum.huawei.com/enterprise/en/data/attachment/forum/202204/21/120858nak5g1epkzwq5gcs.png" width="224px"/><br/>

[![🧼 Pre-commit Hooks](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/pre-commit.yml) [![📚 Terraform Modules CI](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/tf-modules-ci.yaml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/tf-modules-ci.yaml) [![🦫 Go Code Quality Checks](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/go-linter.yaml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/go-linter.yaml)
---

## [Your Module Name Here]

<!-- 📝 Replace this section with your module's description -->
**Brief description of what your Terraform module does and its primary use case.**

This module provides [key functionality] for [target infrastructure/use case]. Built with production-ready practices including comprehensive testing, documentation generation, and portable CI/CD pipelines.

> [!TIP]
> **Quick Start**: Replace the placeholders in this README with your module's specific details. The development workflow and tooling are pre-configured and ready to use. It is essential to provide a clear and comprehensive description of your module. A well-written description helps users understand the purpose and functionality of your module. For more information on how to write effective module descriptions, please refer to the [Terraform Registry documentation](https://registry.terraform.io/).

### ✨ Features
> [!TIP]
> When describing the features of your module, focus on clarity and brevity. Highlight the key functionalities and benefits without unnecessary jargon. This helps users quickly grasp what your module offers and how it can be beneficial for their projects.

<!-- 📝 Replace these with your module's actual features -->
This module provides:

- 🚀 **[Feature 1]**: Description of key capability
- 🚀 **[Feature 2]**: Description of key capability
- 🚀 **[Feature 3]**: Description of key capability
- 🔧 **Production Ready**: Built-in testing, documentation, and CI/CD
- 📦 **Registry Compatible**: Follows Terraform Registry best practices

For examples, see the [`examples/`](./examples/) directory.

### 📦 Available Modules

> [!TIP]
> **Module Organization**: All Terraform modules are organized in the [`modules/`](./modules/) directory following our [Module Guidelines](/docs/terraform-styleguide/terraform-styleguide-modules.md). Each module is self-contained with comprehensive documentation, examples, and tests.

| Module | Description | Use Case |
|--------|-------------|----------|
| [default](./modules/default/) | Template module for creating new infrastructure components | Starting point for new modules, demonstrates best practices |
| [random-string-generator](./modules/random-string-generator/) | Generates random strings with configurable length and character sets | Unique identifiers, suffixes, and random values |
| [read-aws-metadata](./modules/read-aws-metadata/) | Retrieves AWS account metadata (Account ID, Region, Partition) | Environment discovery, dynamic resource naming |

> **Note**: When creating new modules, follow the structure and patterns established in these examples. See our [Module Development Guidelines](/docs/terraform-styleguide/terraform-styleguide-modules.md) for detailed specifications.

## 🔄 Development Workflow

This template includes powerful development tooling with [Dagger](https://dagger.io) for portable CI/CD and [Just](https://just.systems) for command orchestration.

### Prerequisites

**Option 1: Install tools individually**
```bash
# Essential tools
brew install just dagger terraform

# Optional but recommended
brew install pre-commit terraform-docs tflint
```

**Option 2: Use Nix for reproducible environment**
```bash
# Install Nix (if not already installed)
curl -L https://nixos.org/nix/install | sh

# Enter development shell with all tools
nix develop

# Or use with direnv for automatic activation
echo "use flake" > .envrc
direnv allow
```

### Quick Start

1. **Initialize your environment:**
   ```bash
   just init
   ```

2. **Develop your module:**
   ```bash
   # Edit files in modules/default/
   # Add examples in examples/default/basic/
   # Write tests in tests/modules/default/
   ```

3. **Validate as you build:**
   ```bash
   # Run the same pipeline as CI locally
   just pipeline-infra-tf-ci default

   # Or run individual checks
   just tf-validate default
   just pipeline-action-terraform-static-analysis default
   just pipeline-action-terraform-build default
   ```

### Available Commands

**🔍 Core Development:**
```bash
just init                    # Initialize development environment
just tf-validate MODULE      # Validate Terraform code
just tf-fmt MODULE           # Format Terraform code
just tf-docs MODULE          # Generate documentation
```

**🧪 Testing:**
```bash
just tf-test-unit MODULE     # Run unit tests
just tf-test-examples MODULE # Run example tests
just pipeline-infra-tf-ci MODULE  # Full CI pipeline locally
```

**🚀 Pipeline Operations:**
```bash
just pipeline-infra-build    # Build Dagger pipeline
just pipeline-infra-shell    # Interactive debugging
just pipeline-action-terraform-static-analysis MODULE
```

> [!TIP]
> Run `just` to see all available commands. For detailed documentation, see our [Pipeline Guide](/docs/guides/pipeline-guide.md) and [Justfile Recipes Guide](/docs/guides/justfile-recipes-guide.md).

## 🧪 Testing

**Multi-layered testing approach:**

- **Static Analysis**: Terraform validation, formatting, and linting
- **Unit Tests**: Module configuration and output validation
- **Integration Tests**: End-to-end deployment with real resources
- **Example Tests**: All examples are automatically tested

```bash
# Run all tests locally (same as CI)
just pipeline-infra-tf-ci default

# Run specific test types
just tf-test-unit default
just tf-test-examples default
```

Testing is implemented using [Terratest](https://terratest.gruntwork.io/) for reliable infrastructure validation.

## 🌐 CI/CD

**Portable pipeline that runs identically everywhere:**

- **Local Development**: `just pipeline-infra-tf-ci MODULE`
- **GitHub Actions**: Automated on PRs and releases
- **Interactive Debugging**: `just pipeline-infra-shell`

The [Dagger](https://dagger.io) pipeline provides:
- Cross-version Terraform compatibility testing
- AWS integration with multiple auth methods
- Comprehensive static analysis and security scanning
- Parallel execution with intelligent caching

## ⚙️ Configuration

**Environment support:**
- `.env` files (automatically loaded by [Just](https://just.systems))
- Environment variables
- AWS profiles and OIDC
- Terraform workspaces

```bash
# Example .env file
TF_VAR_environment=development
TF_VAR_region=us-west-2
AWS_PROFILE=my-dev-profile
```

See our [Environment Variables Guide](/docs/guides/environment-variables.md) for complete configuration options.

## 🤝 Contributing

We welcome contributions to improve this module!

**Development Standards:**
1. **Fork and clone** this repository
2. **Use the development environment**: Either install tools individually or use our [Nix](https://nixos.org/) flake with `nix develop`
3. **Follow our standards**: [Terraform StyleGuides](/docs/terraform-styleguide/)
4. **Test your changes**: `just pipeline-infra-tf-ci default`
5. **Submit a PR**: We'll review promptly!

**Code Quality Requirements:**
- All code must pass the complete CI pipeline
- New features require tests and documentation
- Follow our coding standards and best practices
- Use conventional commits for automated changelog generation

## 📖 Documentation

### 🎯 Quick Reference
- **[Environment Variables Guide](/docs/guides/environment-variables.md)**: Complete environment configuration
- **[Justfile Recipes Guide](/docs/guides/justfile-recipes-guide.md)**: All available commands
- **[Pipeline Guide](/docs/guides/pipeline-guide.md)**: Comprehensive CI/CD documentation

### 🏗️ Development Standards
- **[Module Guidelines](/docs/terraform-styleguide/terraform-styleguide-modules.md)**: Module design principles
- **[Code Guidelines](/docs/terraform-styleguide/terraform-styleguide-code.md)**: Terraform coding standards
- **[Testing Guidelines](/docs/terraform-styleguide/terraform-styleguide-terratest.md)**: Testing patterns and practices

### 📋 Project Resources
- **[Examples](/examples/README.md)**: Usage examples and patterns
- **[Testing Overview](/tests/README.md)**: Testing strategies
- **[Development Utilities](/scripts/README.md)**: Helper scripts

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with [Terraform Registry Module Template](https://github.com/Excoriate/terraform-registry-module-template)**

*Production-ready tooling • Portable CI/CD • Comprehensive testing*

</div>
