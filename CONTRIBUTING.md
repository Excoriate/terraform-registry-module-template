# Contributing to Terraform Module Development

> [!NOTE]
> Welcome to our Terraform module contribution guide! We're excited to collaborate with you in building high-quality, reusable infrastructure code.

## 🌟 Why Contribute?

> [!TIP]
> By contributing, you're:
>
> - Improving infrastructure as code practices
> - Helping the community build better, more reliable systems
> - Advancing open-source infrastructure tooling

## 📋 Prerequisites

> [!IMPORTANT]
> Ensure you have the following tools installed:
>
> - Go (version specified in `go.mod`)
> - Terraform (version specified in `versions.tf`)
> - pre-commit (latest version)
> - HashiCorp Terraform CLI
> - Docker or compatible containerized runtime
> - Just (task runner)
> - Nix (optional, for development environment)

## 🛠 Development Environment Setup

1. **Fork and Clone**
   ```bash
   # 1. Fork the repository on GitHub
   # 2. Clone your forked repository
   git clone https://github.com/YOUR_GITHUB_USERNAME/terraform-registry-module-template.git
   cd terraform-registry-module-template

   # 3. Add the original repository as a remote
   git remote add upstream https://github.com/Excoriate/terraform-registry-module-template.git
   ```

2. **Install Pre-commit Hooks**
   ```bash
   pre-commit install
   pre-commit install --hook-type commit-msg
   ```

## 🌳 Repository Structure Guidelines

### Module Development

- **Location**: All modules are in the `/modules` directory
- **Mandatory Files for Each Module**:
  ```
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
  └── .tflint.hcl          # TFLint configuration for static analysis
  ```

### Examples and Testing

- Create examples in the `/examples` directory
- Write tests in the `/tests` directory using Terratest
- Ensure comprehensive test coverage

## 🧪 Testing and Validation

> [!IMPORTANT]
> Comprehensive testing is crucial:

### Local Testing Workflow

```bash
# Run pre-commit hooks
just hooks-run

# Run Terraform validations
just tf-validate

# Run Terraform linters
just tf-lint

# Run Go tests
just go-ci

# Run Terraform CI static checks
just tf-ci-static
```

### Continuous Integration

- GitHub Actions will automatically run:
  - Linting checks
  - Unit tests
  - Integration tests
  - Security scans

### Development Workflow

```bash
# Quick development feedback loop for a specific module
just tf-dev                   # Uses default module and basic example
just tf-dev MOD=your-module   # Specify a different module
```

### Nix Development Environment

If you're using Nix, use the `-nix` variants of the commands:

```bash
# Nix-based commands
just hooks-run-nix
just tf-validate-nix
just tf-lint-nix
just go-ci-nix
just tf-ci-static-nix
just tf-dev-nix
```

## 📝 Commit and Branch Guidelines

### Branch Naming

- Use descriptive, lowercase branch names
- Prefix with type of change:
  - `feat/`: New feature
  - `fix/`: Bug fix
  - `docs/`: Documentation updates
  - `refactor/`: Code refactoring
  - `test/`: Adding or updating tests

### Commit Message Convention

Follow Conventional Commits format:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Examples:
- `feat(module): add new AWS networking configuration`
- `fix(validation): correct input variable type`
- `docs: update README with usage examples`

## 🔍 Pull Request Process

1. Update documentation
2. Add/update tests
3. Ensure all CI checks pass
4. Request review from maintainers

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CI checks passing
- [ ] Commits are atomic and focused

## 🛡️ Security Considerations

> [!WARNING]
> Never commit:
>
> - Sensitive information
> - Credentials
> - Personal identifiable information

Refer to our [SECURITY.md](SECURITY.md) for responsible disclosure.

## 📦 Release Process

- Semantic Versioning
- Automated changelog generation
- Maintainer-managed releases

## 🤝 Community Guidelines

- Open an [Issue](https://github.com/Excoriate/terraform-registry-module-template/issues/new)
- Respect our [Code of Conduct](CODE_OF_CONDUCT.md)

## 📚 Learning Resources

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Module Development Guide](https://www.terraform.io/docs/modules/index.html)
- [Contributing to Open Source](https://opensource.guide/how-to-contribute/)

## 🏆 Attribution

Contributions are under the [MIT License](LICENSE)

---

**Thank you for helping improve our Terraform module!** 🎉
