# Scripts Directory

This directory contains utility scripts and pre-commit hooks to support the development workflow of the Terraform module template.

## 📂 Directory Structure

- `utilities/`: Contains utility scripts for common development tasks
- `hooks/`: Pre-commit and other development workflow hooks

## 🛠 Utility Scripts

### `utilities/format.sh`

A script for formatting code across different languages and configuration files.

**Usage:**
```bash
./utilities/format.sh [options]
```

### `utilities/lint-go.sh`

A script for running Go linting checks using golangci-lint.

**Usage:**
```bash
./utilities/lint-go.sh [path_to_go_files]
```

## 🪝 Hooks

Hooks are used to enforce code quality, formatting, and other development standards before commits.

### Pre-Commit Hooks

Refer to the `.pre-commit-config.yaml` for the complete list of pre-commit hooks used in this project.
