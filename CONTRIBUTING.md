# Contributing to this Project

## Welcome Contributors! 🌟

Thank you for your interest in contributing to our project. We're excited to collaborate with you and appreciate your support in making this project better.

## Code of Conduct

By participating, you are expected to uphold our [Code of Conduct](CODE_OF_CONDUCT.md).

### Reporting Violations

If you experience or witness unacceptable behavior, please report it by emailing [project-maintainers@example.com](mailto:project-maintainers@example.com). All complaints will be reviewed and investigated promptly and fairly.

All community leaders are obligated to respect the privacy and security of the reporter of any incident.

## How Can You Contribute?

### 🐛 Reporting Bugs

1. Check the [Issues](../../issues) to ensure the bug hasn't been reported already.
2. Open a new issue using our bug report template.
3. Provide:
   - A clear, descriptive title
   - Steps to reproduce the issue
   - Expected vs. actual behavior
   - Environment details (OS, version, etc.)

### 🚀 Suggesting Enhancements

1. Check existing [Issues](../../issues) to avoid duplicates.
2. Open an issue with our enhancement template.
3. Clearly describe:
   - The proposed enhancement
   - Potential benefits
   - Implementation considerations

## Development Process

### 🍴 Fork & Branch Workflow

1. [Fork the repository](../../fork)
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes, following our coding standards

### 🧪 Testing

- Run all tests before submitting a pull request
- Add tests for new functionality
- Ensure 100% test coverage for new code

### 📝 Commit Guidelines

- Use clear, descriptive commit messages
- Follow [Conventional Commits](https://www.conventionalcommits.org/) standard
- Commits should be atomic and focused

### 🔍 Pull Request Process

1. Update documentation
2. Add tests for new features
3. Ensure all CI checks pass
4. Request a review from maintainers

#### Pull Request Checklist

- [ ] I have read the contribution guidelines
- [ ] My code follows project style guidelines
- [ ] I've added/updated tests
- [ ] Documentation is updated
- [ ] CI checks are passing

## Development Setup

### Prerequisites

- Go (version specified in go.mod)
- Terraform (version specified in versions.tf)
- pre-commit
- Required development tools listed in README

### Local Development

1. Clone your fork
2. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```
3. Run tests:
   ```bash
   just go-test
   just tf-lint
   ```

## Release Process

- Releases follow [Semantic Versioning](https://semver.org/)
- Changelog is automatically generated
- Releases are published by maintainers

## Getting Help

- Open an [Issue](../../issues/new)
- Check our [Discussion](../../discussions) forum
- Reach out to maintainers

## Attribution

Contributions are made under the [MIT License](LICENSE) unless specified otherwise.

---

**Thank you for contributing!** 🎉

[References]

- [GitHub Contributing Guidelines](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/setting-guidelines-for-repository-contributors)
- [Open Source Guides](https://opensource.guide/how-to-contribute/)
