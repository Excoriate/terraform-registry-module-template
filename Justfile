# Justfile for Terraform Module Development
# Load environment variables from .env file
set dotenv-load

# Default task to show available recipes
default:
    @just --list

# 🪝 Initialize pre-commit hooks
install-hooks:
    @echo "🧰 Installing pre-commit hooks..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command pre-commit install

# 🏃 Run pre-commit hooks on all files
run-hooks:
    @echo "🔍 Running pre-commit hooks from .pre-commit-config.yaml..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command pre-commit run --all-files

# 🧹 Clean Terraform and Terragrunt cache directories
clean-tf:
    find . -type d -name ".terraform" -exec rm -rf {} +
    find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

# ℹ️ Display available recipes
help:
    @just --list

# 🧐 Lint YAML files
lint-yaml:
    @echo "🕵️ Linting YAML files..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command yamllint .

# 🐚 Lint shell scripts
lint-shell:
    @echo "🐚 Linting shell scripts..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'find . -type f -name "*.sh" | xargs shellcheck'

# 🦫 Lint Go files
lint-go:
    @echo "🦫 Linting Go files..."
    @chmod +x ./scripts/utilities/lint-go.sh
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/lint-go.sh

# 🌐 Comprehensive linting
lint:
    @echo "🔍 Running comprehensive linting..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c '
    echo "🧐 YAML Linting"
    yamllint .

    echo "🐚 Shell Script Linting"
    find . -type f -name "*.sh" | xargs shellcheck

    echo "🦫 Go Linting"
    golangci-lint run

    echo "✅ Linting complete!"
    '

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

# 🔍 Comprehensive validation using pre-commit
validate:
    @echo "🔍 Running comprehensive validation..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command pre-commit run --all-files

# 🧹 Clean project artifacts using Nix
clean:
    @echo "🗑️ Cleaning project artifacts..."
    @nix develop . --impure --command bash -c '
    find . -type d -name ".terraform" -exec rm -rf {} +
    find . -type d -name ".terragrunt-cache" -exec rm -rf {} +
    '

# 🔧 Format all files using Nix-managed tools
format:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🎨 Formatting all files..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --all

# 🐹 Format only Go files
format-go:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🐹 Formatting Go files..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --go

# 🌿 Format only Terraform files
format-terraform:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🌿 Formatting Terraform files..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --terraform

# 📄 Format only YAML files
format-yaml:
    @chmod +x ./scripts/utilities/format.sh
    @echo "📄 Formatting YAML files..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --yaml

# 🧪 Run tests using Nix
test:
    @echo "🚦 Running tests..."
    @nix develop . --impure --command go test ./...
