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
lint-shell:
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
    @echo "🌿 Starting Nix Development Shell for Terraform Registry Module Template 🏷️"
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes

# 🌍 Allow direnv in the current directory
allow-direnv:
    @echo "🔓 Allowing direnv in the current directory..."
    @direnv allow

# 🔄 Reload direnv environment
reload-direnv:
    @echo "🔁 Reloading direnv environment..."
    @direnv reload

# �� Run all pre-commit checks using Nix
validate:
    @echo "🔍 Running comprehensive validation..."
    @nix develop . --impure --command pre-commit run --all-files

# 🧹 Clean project artifacts using Nix
clean:
    @echo "🗑️ Cleaning project artifacts..."
    @nix develop . --impure --command bash -c '
    find . -type d -name ".terraform" -exec rm -rf {} +
    find . -type d -name ".terragrunt-cache" -exec rm -rf {} +
    '

# 🔍 Lint all files using Nix-managed tools
lint:
    @echo "🕵️ Running comprehensive linting..."
    @nix develop . --impure --command bash -c '
    yamllint .
    find . -type f -name "*.sh" | xargs shellcheck
    golangci-lint run
    '

# 🔧 Format all files using Nix-managed tools
format:
    @echo "🎨 Formatting files..."
    @nix develop . --impure --command bash -c '
    yamlfmt .
    go fmt ./...
    '

# 🧪 Run tests using Nix
test:
    @echo "🚦 Running tests..."
    @nix develop . --impure --command go test ./...
