# 🛠️ Development Tools and Workflow Guide

## 📋 Overview

This guide provides a comprehensive overview of the development tools and workflow recipes available in our Terraform Module Template project. The project uses `just` as a task runner to simplify and standardize development processes.

## 🚀 Prerequisites

Before getting started, ensure you have the following tools installed:
- `just` (task runner)
- `terraform`
- `go`
- `pre-commit`
- `golangci-lint`
- `terraform-docs`
- `tflint`
- `shellcheck`
- `yamllint`

## 🧰 Available Recipes

### 🔧 Environment and Hooks

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `hooks-install` | Install pre-commit hooks locally | `just hooks-install` | Ensures code quality before commits |
| `hooks-run` | Run pre-commit hooks on all files | `just hooks-run` | Validates code before pushing |
| `dev` | Launch Nix development shell | `just dev` | Provides a consistent development environment |

### 🧹 Cleanup Utilities

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `clean-tf` | Remove Terraform cache and state files | `just clean-tf` or `just clean-tf default` | Resets Terraform state |
| `clean` | Remove general project artifacts | `just clean` | Removes logs, DS_Store files |

### 🌿 Terraform Workflow

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `tf-format` | Format Terraform files | `just tf-format` or `just tf-format default` | Ensures consistent code style |
| `tf-lint` | Lint Terraform modules | `just tf-lint` or `just tf-lint default` | Checks for best practices |
| `tf-docs-generate` | Generate module documentation | `just tf-docs-generate` or `just tf-docs-generate default` | Creates README.md for modules |
| `tf-validate` | Validate Terraform modules | `just tf-validate default` | Checks module configuration |
| `tf-cmd` | Run Terraform commands | `just tf-cmd default init` | Flexible Terraform command execution |
| `tf-dev` | Quick development feedback loop | `just tf-dev default basic` | Runs formatting, linting, and initialization |

### 🐹 Go Workflow

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `go-format` | Format Go files | `just go-format` | Ensures Go code style |
| `go-lint` | Lint Go files | `just go-lint` | Checks Go code quality |
| `go-tidy` | Tidy Go module dependencies | `just go-tidy` | Manages Go dependencies |
| `go-tests` | Run Go tests | `just tf-tests default unit` | Runs Terraform module tests |
| `go-ci` | Comprehensive Go checks | `just go-ci` | Runs formatting, linting, and tidying |

### 🌐 YAML Workflow

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `yaml-fix` | Format and lint YAML files | `just yaml-fix` | Ensures YAML consistency |
| `yaml-lint` | Validate YAML files | `just yaml-lint` | Checks YAML configuration |

### 🐚 Shell Script Workflow

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `scripts-lint` | Lint shell scripts | `just scripts-lint` | Checks shell script quality |

## 🔍 Nix Environment Variants

Most recipes have a `-nix` variant (e.g., `go-lint-nix`) that runs the command in a Nix development environment. This ensures consistent tooling across different development setups.

## 💡 Pro Tips

1. Use `just help` to see all available recipes
2. Prefix commands with `just` instead of running tools directly
3. Use module-specific commands by specifying the module name (e.g., `just tf-format default`)
4. Leverage Nix environment variants for reproducible development

## 🚧 Troubleshooting

- If a recipe fails, check the specific error message
- Ensure all prerequisites are installed
- Use the Nix environment (`just dev`) for the most consistent setup

## 📚 Learning Resources

- [Just Documentation](https://just.systems/man/en/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Go Documentation](https://golang.org/doc/)
