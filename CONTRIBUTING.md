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
> Ensure you have:
>
> - Go (version specified in go.mod)
> - Terraform (version specified in versions.tf)
> - pre-commit (latest version available)
> - HashiCorp Terraform CLI
> - Docker or any other containerized runtime (for local testing, and portability)

## 🐛 Reporting Issues

### Bug Reports

> [!WARNING]
> We use a standardized [Bug Report Template](https://github.com/Excoriate/terraform-registry-module-template/blob/main/.github/ISSUE_TEMPLATE/bug_report.md) to ensure we get all necessary information.

When reporting a bug:

- Use the [Bug Report Template](https://github.com/Excoriate/terraform-registry-module-template/blob/main/.github/ISSUE_TEMPLATE/bug_report.md)
- Provide all requested details
- Be clear and concise
- Include a minimal reproducible example

### Feature Requests

> [!TIP]
> We have a [Feature Request Template](https://github.com/Excoriate/terraform-registry-module-template/blob/main/.github/ISSUE_TEMPLATE/feature_request.md) to help structure your suggestions.

When suggesting enhancements:

- Use the [Feature Request Template](https://github.com/Excoriate/terraform-registry-module-template/blob/main/.github/ISSUE_TEMPLATE/feature_request.md)
- Explain your use case thoroughly
- Provide context and potential implementation approach
- Consider the module's scope and portability

## 🚀 Development Workflow

### 1. Fork and Clone

```bash
# 1. Fork the repository on GitHub
# 2. Clone your forked repository
git clone https://github.com/YOUR_GITHUB_USERNAME/terraform-registry-module-template.git
cd terraform-registry-module-template

# 3. Add the original repository as a remote (optional, but recommended)
git remote add upstream https://github.com/Excoriate/terraform-registry-module-template.git
```

### 2. Create a Branch

```bash
# Use conventional branch naming
git checkout -b feat/your-feature-name
# or
git checkout -b fix/issue-description
```

## 🧪 Testing and Validation

> [!IMPORTANT]
> Comprehensive testing is crucial:

### Local Testing

```bash
# Run pre-commit hooks
pre-commit run --all-files

# Run Terraform validations
terraform fmt -check
terraform validate

# Run unit tests
just go-test
just tf-lint

# Integration testing
terratest test ./...
```

### Continuous Integration

- GitHub Actions will run:
  - Linting
  - Unit tests
  - Integration tests
  - Security scans

## 📝 Commit Guidelines

> [!TIP]
> Follow Conventional Commits:

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
3. Ensure CI checks pass
4. Request review from maintainers

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CI checks passing
- [ ] Commits are atomic and focused

## 🛡️ Security

> [!WARNING]
> Never commit:
>
> - Sensitive information
> - Credentials
> - Personal identifiable information

Refer to our [SECURITY.md](https://github.com/Excoriate/terraform-registry-module-template/blob/main/SECURITY.md) for responsible disclosure.

## 📦 Release Process

- Semantic Versioning
- Automated changelog generation
- Maintainer-managed releases

## 🤝 Community

- Open an [Issue](https://github.com/Excoriate/terraform-registry-module-template/issues/new)
- Respect our [Code of Conduct](https://github.com/Excoriate/terraform-registry-module-template/blob/main/CODE_OF_CONDUCT.md)

## 📚 Learning Resources

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Module Development Guide](https://www.terraform.io/docs/modules/index.html)
- [Contributing to Open Source](https://opensource.guide/how-to-contribute/)

## 🏆 Attribution

Contributions are under the [MIT License](https://github.com/Excoriate/terraform-registry-module-template/blob/main/LICENSE)

---

**Thank you for helping improve our Terraform module!** 🎉
