# Development Scripts 🛠️

## 📘 Directory Purpose

This directory contains utility scripts and hooks that support the development workflow of the Terraform module template, ensuring:
- Code quality
- Consistent formatting
- Automated checks
- Efficient development processes

## 📂 Directory Structure

```text
scripts/
├── utilities/     # Utility scripts for development tasks
│   ├── format.sh     # Cross-language code formatting script
│   ├── tflint.sh    # TFLint script for Terraform files
│   └── tfdocs.sh    # tfdocs script for Terraform modules
│   └── ...           # Additional utility scripts
└── hooks/        # Pre-commit and workflow management hooks
    ├── pre-commit-init.sh  # Pre-commit hook initialization
    └── ...           # Additional hook scripts
```

## 🧰 Utility Scripts

### `utilities/format.sh`

A comprehensive script for formatting code across multiple languages and configuration files.

**Features:**
- Cross-language code formatting support
- Configurable formatting options
- Integration with project-wide formatting standards

**Usage:**
```bash
# Run formatting script
./utilities/format.sh [options]

# Common options
# --check   Validate formatting without changes
# --fix     Apply formatting fixes
# --lang    Specify target language(s)
```

### `utilities/tflint.sh`

A script to run TFLint on Terraform files for checking syntax, style, and best practices.

**Features:**
- Runs TFLint with a predefined configuration
- Supports targeting specific modules
- Can be run in a Nix environment

**Usage:**
```bash
# Run TFLint on all files in the current directory
./utilities/tflint.sh

# Run TFLint for a specific module
./utilities/tflint.sh --module mymodule

# Run TFLint in a Nix environment
./utilities/tflint.sh --nix
```

### `utilities/tfdocs.sh`

A script to generate documentation for Terraform modules using `terraform-docs`.

**Features:**
- Automates documentation generation
- Supports targeting specific modules
- Can be run in a Nix environment

**Usage:**
```bash
# Generate docs for all modules
./utilities/tfdocs.sh

# Generate docs for a specific module
./utilities/tfdocs.sh --module mymodule

# Generate docs in a Nix environment
./utilities/tfdocs.sh --nix
```

## 🪝 Hooks Management

### Pre-Commit Hooks

Pre-commit hooks are used to enforce:
- Code formatting
- Linting
- Security checks
- Consistent code style

**Key Hook Categories:**
- YAML formatting
- Go code linting
- Terraform formatting
- Shell script checks
- Security scanning

## 🔍 Development Workflow Integration

These scripts integrate seamlessly with the project's development process:
- Used in CI/CD pipelines
- Enforced through pre-commit hooks
- Accessible via `just` command runner

## 💡 Best Practices

- Always run formatting and linting before committing
- Use provided scripts to maintain code quality
- Refer to project-wide configuration files

## 🚀 Quick Reference Commands

```bash
# Install pre-commit hooks
just hooks-install

# Run pre-commit checks
just hooks-run

# Format code across different languages
just yaml-fix
just go-format
just tf-format
just scripts-lint
```

## 🔒 Security Considerations

- Scripts are designed with minimal system impact
- No destructive operations without explicit user confirmation
- Follows principle of least privilege

## 🔄 Continuous Improvement

- Regular review of utility scripts
- Update hooks to reflect latest best practices
- Encourage team feedback on development tools

## 📚 References

- [Pre-Commit Hooks](https://pre-commit.com/)
- [Just Command Runner](https://github.com/casey/just)
- [Terraform Development Best Practices](https://www.terraform.io/docs/language/modules/develop/)

**Note:** This directory's scripts are critical to maintaining code quality and development efficiency.
