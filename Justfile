# 🚀 Terraform Module Development Workflow: Automate setup, formatting, linting, and project management
#
# This Justfile provides a comprehensive set of tasks for managing
# Terraform module development, including:
# - Environment setup
# - Code formatting
# - Linting
# - Pre-commit hooks
# - Cleanup utilities
#
# Usage:
#   just <recipe>           # Run a specific task
#   just                    # Show available tasks
#   just help               # List all available recipes

# 🌍 Load environment variables from .env file for consistent configuration
set dotenv-load

# 🎯 Default task: Display available recipes when no specific task is specified
default: help

# ℹ️ List all available recipes with their descriptions
help:
    @just --list

# 🔧 Install pre-commit hooks in Nix environment for consistent code quality
install-hooks-nix:
    @echo "🧰 Installing pre-commit hooks in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command pre-commit install

# 🔧 Install pre-commit hooks in local environment for code consistency
install-hooks:
    @echo "🧰 Installing pre-commit hooks locally..."
    @./scripts/hooks/pre-commit-init.sh init

# 🕵️ Run pre-commit hooks across all files in Nix environment
run-hooks-nix:
    @echo "🔍 Running pre-commit hooks from .pre-commit-config.yaml in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command pre-commit run --all-files

# 🕵️ Run pre-commit hooks across all files in local environment
run-hooks:
    @echo "🔍 Running pre-commit hooks from .pre-commit-config.yaml..."
    @./scripts/hooks/pre-commit-init.sh run

# 🧹 Remove Terraform and Terragrunt cache directories to reset project state
clean-tf:
    @echo "🗑️ Cleaning Terraform and Terragrunt cache directories..."
    @find . -type d -name ".terraform" -exec rm -rf {} +
    @find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

# 🧹 Comprehensive cleanup of project artifacts, state files, and cache directories
clean:
    @echo "🗑️ Performing comprehensive project cleanup..."
    @find . -type d -name ".terraform" -exec rm -rf {} +
    @find . -type d -name ".terragrunt-cache" -exec rm -rf {} +
    @find . -type f -name "*.tfstate" -exec rm -f {} +
    @find . -type f -name "*.tfstate.backup" -exec rm -f {} +

# 🧐 Format YAML files using yamlfmt in Nix environment
fix-yaml-nix:
    @echo "🔧 Formatting YAML files with yamlfmt in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command yamlfmt .

# 🧹 Format and lint YAML files for consistency and quality
fix-yaml:
    @echo "🔧 Formatting and linting YAML files..."
    @yamlfmt .
    @echo "🕵️ Validating YAML configuration..."
    @yamllint --config-file .yamllint.yml --strict .
    @echo "✅ YAML formatting and linting complete!"

# 🕵️ Lint YAML files using yamllint in Nix environment
lint-yaml-nix:
    @echo "🕵️ Linting YAML files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command yamllint .

# 🕵️ Validate YAML files against strict configuration standards
lint-yaml:
    @echo "🕵️ Linting YAML files..."
    @yamlfmt .
    @echo "🕵️ Checking yamllint configuration..."
    @yamllint --config-file .yamllint.yml --strict .
    @echo "✅ YAML formatting and linting complete!"

# 🐚 Lint shell scripts using shellcheck in Nix environment
lint-shell-nix:
    @echo "🐚 Linting shell scripts in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'find . -type f -name "*.sh" | xargs shellcheck'

# 🐚 Perform static analysis on all shell scripts
lint-shell:
    @echo "🐚 Linting shell scripts..."
    @find . -type f -name "*.sh" | xargs shellcheck

# 🦫 Lint Go files using custom script in Nix environment
lint-go-nix:
    @echo "🦫 Linting Go files in Nix environment..."
    @chmod +x ./scripts/utilities/lint-go.sh
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/lint-go.sh

# 🦫 Perform static code analysis on Go files
lint-go:
    @echo "🦫 Linting Go files..."
    @chmod +x ./scripts/utilities/lint-go.sh
    @./scripts/utilities/lint-go.sh

# 🚀 Launch Nix development shell with project dependencies
dev:
    @echo "🌿 Starting Nix Development Shell for Terraform Registry Module Template 🏷️"
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes

# 🔓 Enable direnv for environment variable management
allow-direnv:
    @echo "🔓 Allowing direnv in the current directory..."
    @direnv allow

# 🔄 Reload direnv environment configuration
reload-direnv:
    @echo "🔁 Reloading direnv environment..."
    @direnv reload

# 🎨 Format all files using custom script in Nix environment
format-all-nix:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🎨 Formatting all files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --all

# 🎨 Apply consistent formatting across entire project
format-all:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🎨 Formatting all files..."
    @./scripts/utilities/format.sh --all

# 🐹 Format Go files using custom script in Nix environment
format-go-nix:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🐹 Formatting Go files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --go

# 🐹 Apply Go-specific code formatting
format-go:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🐹 Formatting Go files..."
    @./scripts/utilities/format.sh --go

# 🌿 Format Terraform files using custom script in Nix environment
format-terraform-nix:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🌿 Formatting Terraform files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --terraform

# 🌿 Apply Terraform-specific code formatting
format-terraform:
    @chmod +x ./scripts/utilities/format.sh
    @echo "🌿 Formatting Terraform files..."
    @./scripts/utilities/format.sh --terraform

# 📄 Format YAML files using custom script in Nix environment
format-yaml-nix:
    @chmod +x ./scripts/utilities/format.sh
    @echo "📄 Formatting YAML files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --yaml

# 📄 Apply YAML-specific file formatting
format-yaml:
    @chmod +x ./scripts/utilities/format.sh
    @echo "📄 Formatting YAML files..."
    @./scripts/utilities/format.sh --yaml

root_dir := "."
modules_dir := "modules"
examples_dir := "examples"
module_dir := "."

# 🌿 Run Terraform commands in Nix environment
run-tf-nix MOD='.' *CMDS='--help':
    @echo "🏗️ Running Terraform command in Nix environment:"
    @echo "   Command: terraform {{CMDS}}"
    @echo "   Working directory: $(realpath {{module_dir}})"
    @cd {{module_dir}} && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform {{CMDS}}

# 🌿 Run Terraform commands
run-tf MOD='.' CMDS='--help':
    @echo "🏗️ Running Terraform command:"
    @echo "   Command: terraform {{CMDS}}"
    @echo "   Working directory: $(realpath {{module_dir}})"
    @cd {{module_dir}} && terraform {{CMDS}}

# 🌿 Run OpenTofu commands in Nix environment
run-tofu-nix MOD='.' CMDS='--help':
    @echo "🏗️ Running OpenTofu command in Nix environment:"
    @echo "   Command: tofu {{CMDS}}"
    @echo "   Working directory: $(realpath {{module_dir}})"
    @cd {{module_dir}} && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command tofu {{CMDS}}

# 🌿 Run OpenTofu commands
run-tofu MOD='.' CMDS='--help':
    @echo "🏗️ Running OpenTofu command:"
    @echo "   Command: tofu {{CMDS}}"
    @echo "   Working directory: $(realpath {{module_dir}})"
    @cd {{module_dir}} && tofu {{CMDS}}

# 🐳 Build multi-arch Docker image for Terraform and OpenTofu
build-docker-multiarch TERRAFORM_VERSION='1.10.5' OPENTOFU_VERSION='1.9.0' REGISTRY='local' TAG='latest':
    @echo "🏗️ Building multi-arch Docker image with Terraform v{{TERRAFORM_VERSION}} and OpenTofu v{{OPENTOFU_VERSION}}..."
    @docker buildx create --use --name multiarch-builder || true
    @docker buildx inspect multiarch-builder --bootstrap
    @docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --build-arg TERRAFORM_VERSION={{TERRAFORM_VERSION}} \
        --build-arg OPENTOFU_VERSION={{OPENTOFU_VERSION}} \
        -t {{REGISTRY}}/terraform-opentofu-cli:{{TERRAFORM_VERSION}}-{{OPENTOFU_VERSION}}-{{TAG}} \
        --push .

# 🚀 Run Terraform commands in multi-arch Docker container
run-tf-docker-multiarch MOD='.' CMDS='--help' TERRAFORM_VERSION='1.10.5' ARCH='amd64':
    @echo "🐳 Running Terraform command in multi-arch Docker ({{ARCH}}):"
    @echo "   Command: terraform {{CMDS}}"
    @echo "   Working directory: {{MOD}}"
    @docker run --platform linux/{{ARCH}} --rm -it \
        -v "$(realpath {{MOD}}):/workspace" \
        -w /workspace \
        local/terraform-opentofu-cli:{{TERRAFORM_VERSION}}-1.9.0-latest \
        terraform {{CMDS}}

# 🚀 Run OpenTofu commands in multi-arch Docker container
run-tofu-docker-multiarch MOD='.' CMDS='--help' OPENTOFU_VERSION='1.9.0' ARCH='amd64':
    @echo "🐳 Running OpenTofu command in multi-arch Docker ({{ARCH}}):"
    @echo "   Command: tofu {{CMDS}}"
    @echo "   Working directory: {{MOD}}"
    @docker run --platform linux/{{ARCH}} --rm -it \
        -v "$(realpath {{MOD}}):/workspace" \
        -w /workspace \
        local/terraform-opentofu-cli:1.10.5-{{OPENTOFU_VERSION}}-latest \
        tofu {{CMDS}}

# 🔍 Inspect multi-arch Docker image details
inspect-docker-multiarch TERRAFORM_VERSION='1.10.5' OPENTOFU_VERSION='1.9.0':
    @echo "🕵️ Inspecting multi-arch Docker image..."
    @docker buildx imagetools inspect local/terraform-opentofu-cli:{{TERRAFORM_VERSION}}-{{OPENTOFU_VERSION}}-latest
