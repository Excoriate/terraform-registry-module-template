# Justfile for Terraform Module Development
# Load environment variables from .env file
set dotenv-load

# Default task to show available recipes
default:
    @just --list

# 🪝 Initialize pre-commit hooks
install-hooks:
    @echo "🧰Installing pre-commit hooks..."
    @./scripts/hooks/pre-commit-init.sh init

# 🏃 Run pre-commit hooks on all files
run-hooks:
    @echo "🔍 Running pre-commit hooks from .pre-commit-config.yaml..."
    @./scripts/hooks/pre-commit-init.sh run

# 🧹 Clean Terraform and Terragrunt cache directories
clean-tf:
    find . -type d -name ".terraform" -exec rm -rf {} +
    find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

# ℹ️ Display available recipes
help:
    @just --list

# 🧐 Lint YAML files
lint-yaml:
    yamllint .

# 🐚 Lint shell scripts
shell-lint:
    find . -type f -name "*.sh" | xargs shellcheck

# 🧹 Fix and Lint YAML files
fix-yaml:
    @echo "🔧 Formatting YAML files with yamlfmt..."
    @yamlfmt .
    @echo "🕵️ Checking yamllint configuration..."
    @yamllint --config-file .yamllint.yml --strict .
    @echo "✅ YAML formatting and linting complete!"

# Start Nix development shell 🚀
start-devshell:
    @echo "🌿 Starting Nix Development Shell for AWS Taggy 🏷️"
    @nix develop . --extra-experimental-features nix-command --extra-experimental-features flakes
