# Justfile for Terraform Module Development
# Load environment variables from .env file
set dotenv-load

# Default task to show available recipes
default:
    @just --list

# 🪝 Initialize pre-commit hooks
install-hooks:
    bash scripts/hooks/pre-commit-init.sh init

# 🏃 Run pre-commit hooks on all files
run-hooks
    bash scripts/hooks/pre-commit-init.sh run

# 🧹 Clean Terraform and Terragrunt cache directories
clean-tf:
    find . -type d -name ".terraform" -exec rm -rf {} +
    find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

# ℹ️ Display available recipes
help:
    @just --list

# 🧐 Lint YAML files
yaml-lint:
    yamllint .

# 🐚 Lint shell scripts
shell-lint:
    find . -type f -name "*.sh" | xargs shellcheck

# 🔍 Comprehensive linting task
lint: yaml-lint shell-lint
