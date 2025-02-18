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

# 📦 Variables for project directories
TESTS_DIR := 'tests'
MODULES_DIR := 'modules'
EXAMPLES_DIR := 'examples'

# ℹ️ List all available recipes with their descriptions
help:
    @just --list

# 🔧 Install pre-commit hooks in Nix environment for consistent code quality
hooks-install-nix:
    @echo "🧰 Installing pre-commit hooks in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command pre-commit install

# 🔧 Install pre-commit hooks in local environment for code consistency
hooks-install:
    @echo "🧰 Installing pre-commit hooks locally..."
    @./scripts/hooks/pre-commit-init.sh init

# 🕵️ Run pre-commit hooks across all files in Nix environment
hooks-run-nix:
    @echo "🔍 Running pre-commit hooks from .pre-commit-config.yaml in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command pre-commit run --all-files

# 🕵️ Run pre-commit hooks across all files in local environment
hooks-run:
    @echo "🔍 Running pre-commit hooks from .pre-commit-config.yaml..."
    @./scripts/hooks/pre-commit-init.sh run

# 🧹 Remove Terraform and Terragrunt cache directories to reset project state
clean-tf MOD='':
    @echo "🗑️ Cleaning Terraform and Terragrunt cache directories..."
    @if [ -z "{{MOD}}" ]; then \
        find . -type d -name ".terraform" -exec rm -rf {} +; \
        find . -type d -name ".terragrunt-cache" -exec rm -rf {} +; \
        find . -type f -name "*.tfstate" -exec rm -f {} +; \
        find . -type f -name "*.tfstate.backup" -exec rm -f {} +; \
    else \
        echo "🧹 Cleaning Terraform artifacts for module: {{MOD}}"; \
        echo "   🔍 Cleaning module directory..."; \
        find "{{MODULES_DIR}}/{{MOD}}" -type d -name ".terraform" -exec rm -rf {} +; \
        find "{{MODULES_DIR}}/{{MOD}}" -type d -name ".terragrunt-cache" -exec rm -rf {} +; \
        find "{{MODULES_DIR}}/{{MOD}}" -type f -name "*.tfstate" -exec rm -f {} +; \
        find "{{MODULES_DIR}}/{{MOD}}" -type f -name "*.tfstate.backup" -exec rm -f {} +; \
        \
        echo "   🔍 Cleaning example directories..."; \
        find "{{EXAMPLES_DIR}}/{{MOD}}" -type d -name ".terraform" -exec rm -rf {} +; \
        find "{{EXAMPLES_DIR}}/{{MOD}}" -type d -name ".terragrunt-cache" -exec rm -rf {} +; \
        find "{{EXAMPLES_DIR}}/{{MOD}}" -type f -name "*.tfstate" -exec rm -f {} +; \
        find "{{EXAMPLES_DIR}}/{{MOD}}" -type f -name "*.tfstate.backup" -exec rm -f {} +; \
    fi

# 🧹 Comprehensive cleanup of project artifacts, state files, and cache directories
clean:
    @echo "🗑️ Performing comprehensive project cleanup for general purposes..."
    @find . -name ".DS_Store" -exec rm -f {} +
    @find . -name "*.log" -exec rm -f {} +

# 🧹 Comprehensive cleanup of project artifacts, state files, and cache directories in Nix environment
clean-all: clean clean-tf

# 🧐 Format YAML files using yamlfmt in Nix environment
yaml-fix-nix:
    @echo "🔧 Formatting YAML files with yamlfmt in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command yamlfmt .

# 🧹 Format and lint YAML files for consistency and quality
yaml-fix:
    @echo "🔧 Formatting and linting YAML files..."
    @yamlfmt .
    @echo "🕵️ Validating YAML configuration..."
    @yamllint --config-file .yamllint.yml --strict .
    @echo "✅ YAML formatting and linting complete!"

# 🕵️ Lint YAML files using yamllint in Nix environment
yaml-lint-nix:
    @echo "🕵️ Linting YAML files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command yamllint .

# 🕵️ Validate YAML files against strict configuration standards
yaml-lint:
    @echo "🕵️ Linting YAML files..."
    @yamlfmt .
    @echo "🕵️ Checking yamllint configuration..."
    @yamllint --config-file .yamllint.yml --strict .
    @echo "✅ YAML formatting and linting complete!"

# 🐚 Lint shell scripts using shellcheck in Nix environment
scripts-lint-nix:
    @echo "🐚 Linting shell scripts in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'find . -type f -name "*.sh" | xargs shellcheck'

# 🐚 Perform static analysis on all shell scripts
scripts-lint:
    @echo "🐚 Linting shell scripts..."
    @find . -type f -name "*.sh" | xargs shellcheck

# 🦫 Lint Go files using custom script in Nix environment
go-lint-nix:
    @echo "🦫 Linting Go files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'cd tests/ && go mod tidy && golangci-lint run --verbose --config ../.golangci.yml'

# 🦫 Perform static code analysis on Go files
go-lint:
    @echo "🦫 Linting Go files..."
    @cd tests/ && go mod tidy && golangci-lint run --verbose --config ../.golangci.yml

# 🐹 Format Go files in Nix environment using gofmt
go-format-nix:
    @echo "🐹 Formatting Go files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'find . -type f -name "*.go" -not -path "*/vendor/*" -exec gofmt -w {} +'

# 🐹 Format Go files locally within the tests directory
go-format:
    @echo "🐹 Formatting Go files in tests directory..."
    @cd tests && \
    echo "📋 Go files to be formatted:" && \
    find . -type f -name "*.go" -not -path "*/vendor/*" | tee /dev/tty | xargs gofmt -w

# 🐹 Tidy Go files in Nix environment
go-tidy-nix:
    @echo "🐹 Tidying Go files in Nix environment..."
    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'cd tests/ && go mod tidy'

# 🐹 Tidy Go files locally within the tests directory
go-tidy:
    @echo "🐹 Tidying Go files in tests directory..."
    @cd tests && go mod tidy

# 🐹 Comprehensive CI checks for Go files
go-ci: (go-tidy) (go-format) (go-lint)
    @echo "✅ Go files CI checks completed"

go-ci-nix: (go-tidy-nix) (go-format-nix) (go-lint-nix)
    @echo "✅ Go files CI checks completed in Nix environment"

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

# 🌿 Format Terraform files locally using terraform fmt
tf-format MOD='':
    @echo "🌿 Discovering Terraform files..."
    @if [ -z "{{MOD}}" ]; then \
        find . -type f \( -name "*.tf" -o -name "*.tfvars" \) | sort | while read -r file; do \
            echo "📄 Found: $file"; \
        done; \
        find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -recursive; \
    else \
        echo "📂 Formatting Terraform files in directory: {{{{MODULES_DIR}}/{{MOD}}}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -recursive; \
        cd - > /dev/null; \
        cd "{{EXAMPLES_DIR}}/{{MOD}}" && find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -recursive; \
        cd - > /dev/null; \
    fi

# 🌿 Format Terraform files in Nix development environment
tf-format-nix MOD='':
    @echo "🌿 Discovering Terraform files in Nix environment..."
    @if [ -z "{{MOD}}" ]; then \
        nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -recursive; \
    else \
        echo "📂 Formatting Terraform files in directory: {{MODULES_DIR}}/{{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -recursive; \
        cd - > /dev/null; \
        echo "📂 Formatting Terraform files in directory: {{EXAMPLES_DIR}}/{{MOD}}"; \
        cd "{{EXAMPLES_DIR}}/{{MOD}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -recursive; \
        cd - > /dev/null; \
    fi

# 🌿 Format Terraform files in Nix development environment
tf-format-check-nix MOD='':
    @echo "🌿 Discovering Terraform files in Nix environment..."
    @if [ -z "{{MOD}}" ]; then \
        nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -check -recursive; \
    else \
        echo "📂 Formatting Terraform files in directory: {{MODULES_DIR}}/{{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -check -recursive; \
        cd - > /dev/null; \
        echo "📂 Formatting Terraform files in directory: {{EXAMPLES_DIR}}/{{MOD}}"; \
        cd "{{EXAMPLES_DIR}}/{{MOD}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -check -recursive; \
        cd - > /dev/null; \
    fi

# 🌿 Format Terraform files locally using terraform fmt
tf-format-check MOD='':
    @echo "🌿 Discovering Terraform files..."
    @if [ -z "{{MOD}}" ]; then \
        find . -type f \( -name "*.tf" -o -name "*.tfvars" \) | sort | while read -r file; do \
            echo "📄 Found: $file"; \
        done; \
        find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -check -recursive; \
    else \
        echo "📂 Formatting Terraform files in directory: {{MODULES_DIR}}/{{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -check -recursive; \
        cd - > /dev/null; \
        cd "{{EXAMPLES_DIR}}/{{MOD}}" && find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -check -recursive; \
        cd - > /dev/null; \
    fi

# 🌿 Run tests for Terraform module locally
tf-tests MOD='default' TYPE='unit':
    @echo "🏗️ Running tests for Terraform module: {{TESTS_DIR}}/modules/{{MOD}}/{{TYPE}}..."
    @cd {{TESTS_DIR}}/modules/{{MOD}}/{{TYPE}} && go test -v

# 🌿 Run tests for Terraform module in Nix development environment
tf-tests-nix MOD='default' TYPE='unit':
    @echo "🏗️ Running tests for Terraform module: {{TESTS_DIR}}/modules/{{MOD}}/{{TYPE}} in Nix environment..."
    @cd {{TESTS_DIR}}/modules/{{MOD}}/{{TYPE}} && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command go test -v

# 🌿 Run Terraform commands with flexible working directory and command selection
tf-exec WORKDIR='.' CMDS='--help':
    @echo "🏗️ Running Terraform command:"
    @echo "👨🏻‍💻 Command: terraform {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{WORKDIR}})"
    @cd "{{WORKDIR}}" && terraform {{CMDS}}

# 🌿 Run Terraform commands in Nix development environment with flexible working directory and command selection
tf-exec-nix WORKDIR='.' CMDS='--help':
    @echo "🏗️ Running Terraform command in Nix environment:"
    @echo "👨🏻‍💻 Command: terraform {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{WORKDIR}})"
    @cd "{{WORKDIR}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform {{CMDS}}

# 🌿 Run Terraform commands locally with flexible module and command selection
tf-cmd MOD='.' CMDS='--help':
    @echo "🏗️ Running Terraform command:"
    @echo "👨🏻‍💻 Command: terraform {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{MODULES_DIR}}/{{MOD}})"
    @cd "{{MODULES_DIR}}/{{MOD}}" && terraform {{CMDS}}

# 🌿 Run Terraform commands in Nix development environment with flexible module and command selection
tf-cmd-nix MOD='.' CMDS='--help':
    @echo "🏗️ Running Terraform command in Nix environment:"
    @echo "👨🏻‍💻 Command: terraform {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{MODULES_DIR}}/{{MOD}})"
    @cd "{{MODULES_DIR}}/{{MOD}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform {{CMDS}}

# 🌿 Run OpenTofu commands locally with flexible module and command selection
tofu-cmd MOD='.' CMDS='--help':
    @echo "🏗️ Running OpenTofu command:"
    @echo "👨🏻‍💻 Command: tofu {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{MODULES_DIR}}/{{MOD}})"
    @cd "{{MODULES_DIR}}/{{MOD}}" && tofu {{CMDS}}

# 🌿 Run OpenTofu commands in Nix development environment with flexible module and command selection
tofu-cmd-nix MOD='.' CMDS='--help':
    @echo "🏗️ Running OpenTofu command in Nix environment:"
    @echo "👨🏻‍💻 Command: tofu {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{MODULES_DIR}}/{{MOD}})"
    @cd "{{MODULES_DIR}}/{{MOD}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command tofu {{CMDS}}

# 🔍 Lint Terraform modules locally using tflint, supporting directory-wide or specific module linting
tf-lint MOD='':
    @echo "🔍 Discovering and linting Terraform modules..."
    @if [ -z "{{MOD}}" ]; then \
        for dir in $(find modules examples -type f -name ".tflint.hcl" | xargs -I {} dirname {}); do \
            echo "🕵️ Linting directory: $dir"; \
            cd $dir && \
            tflint --recursive && \
            cd - > /dev/null; \
        done \
    else \
        echo "🕵️ Linting module directory: {{MODULES_DIR}}/{{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && \
        tflint --recursive && \
        cd - > /dev/null; \
        \
        echo "🕵️ Linting example subdirectories for module: {{MOD}}"; \
        for example_dir in $(find "{{EXAMPLES_DIR}}/{{MOD}}" -type f -name ".tflint.hcl" | xargs -I {} dirname {} | sort -u); do \
            echo "   📂 Linting example directory: $example_dir"; \
            cd "$example_dir" && \
            tflint --recursive && \
            cd - > /dev/null; \
        done; \
    fi

# 🔍 Lint Terraform modules in Nix development environment using tflint, supporting directory-wide or specific module linting
tf-lint-nix MOD='':
    @echo "🔍 Discovering and linting Terraform modules in Nix environment..."
    @if [ -z "{{MOD}}" ]; then \
        for dir in $(find modules examples -type f -name ".tflint.hcl" | xargs -I {} dirname {}); do \
            echo "🕵️ Linting directory: $dir"; \
            cd $dir && \
            nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command tflint --recursive && \
            cd - > /dev/null; \
        done \
    else \
        echo "🕵️ Linting module directory: {{MODULES_DIR}}/{{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && \
        nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command tflint --recursive && \
        cd - > /dev/null; \
        \
        echo "🕵️ Linting example subdirectories for module: {{MOD}}"; \
        for example_dir in $(find "{{EXAMPLES_DIR}}/{{MOD}}" -type f -name ".tflint.hcl" | xargs -I {} dirname {} | sort -u); do \
            echo "   📂 Linting example directory: $example_dir"; \
            cd "$example_dir" && \
            nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command tflint --recursive && \
            cd - > /dev/null; \
        done; \
    fi

# 📄 Generate Terraform module documentation locally using terraform-docs, supporting multiple modules
tf-docs-generate MOD='':
    @echo "🔍 Generating Terraform module documentation..."
    @if [ -z "{{MOD}}" ]; then \
        for dir in $(find modules examples -type f -name ".terraform-docs.yml" | xargs -I {} dirname {} | sort -u); do \
            echo "📄 Attempting to generate docs for: $dir"; \
            if [ -d "$dir" ]; then \
                cd "$dir" && \
                echo "   🔧 Current directory: $(pwd)" && \
                terraform-docs markdown . --output-file README.md || \
                echo "   ❌ Documentation generation failed for $dir" && \
                cd - > /dev/null; \
            else \
                echo "   ❌ Directory not found: $dir"; \
            fi \
        done \
    else \
        echo "📄 Generating docs for specified module: {{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && \
        terraform-docs markdown . --output-file README.md || \
        echo "❌ Documentation generation failed for {{MOD}}"; \
    fi

# 📄 Generate Terraform module documentation in Nix development environment using terraform-docs, supporting multiple modules
tf-docs-generate-nix MOD='':
    @echo "🔍 Generating Terraform module documentation in Nix environment..."
    @if [ -z "{{MOD}}" ]; then \
        for dir in $(find modules examples -type f -name ".terraform-docs.yml" | xargs -I {} dirname {} | sort -u); do \
            echo "📄 Attempting to generate docs for: $dir"; \
            cd "$dir" && \
            nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'terraform-docs markdown . --output-file README.md' && \
            echo "   ✅ Documentation generated successfully for $dir" || \
            echo "   ❌ Documentation generation failed for $dir" && \
            cd - > /dev/null; \
        done \
    else \
        echo "📄 Generating docs for module directory: {{MODULES_DIR}}/{{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && \
        nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'terraform-docs markdown . --output-file README.md' && \
        echo "   ✅ Documentation generated successfully for module" || \
        echo "   ❌ Documentation generation failed for module" && \
        cd - > /dev/null; \
        \
        echo "📄 Generating docs for example subdirectories for module: {{MOD}}"; \
        for example_dir in $(find "{{EXAMPLES_DIR}}/{{MOD}}" -type f -name ".terraform-docs.yml" | xargs -I {} dirname {} | sort -u); do \
            echo "   📂 Generating docs for example directory: $example_dir"; \
            cd "$example_dir" && \
            nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'terraform-docs markdown . --output-file README.md' && \
            echo "   ✅ Documentation generated successfully for example" || \
            echo "   ❌ Documentation generation failed for example" && \
            cd - > /dev/null; \
        done; \
    fi

# 📄 Validate Terraform modules locally using terraform validate
tf-validate MOD='': (tf-cmd MOD 'init -backend=false') (tf-cmd MOD 'validate')

# 📄 Validate Terraform modules in Nix development environment using terraform validate
tf-validate-nix MOD='': (tf-cmd-nix MOD 'init -backend=false') (tf-cmd-nix MOD 'validate')

# 📄 Run Terraform CI checks locally (only static, like 'fmt', 'lint', 'docs')
tf-ci-static MOD='': (tf-format-check MOD) (tf-lint MOD) (tf-docs-generate MOD) (tf-validate MOD)

# 📄 Run Terraform CI checks in Nix development environment
tf-ci-static-nix MOD='': (tf-format-check-nix MOD) (tf-lint-nix MOD) (tf-docs-generate-nix MOD) (tf-validate-nix MOD)

# 🌀 Quick feedback loop for development
tf-dev MOD='default' EXAMPLE='basic':
    @just tf-ci-static "{{MOD}}"
    @just tf-cmd "{{MOD}}" 'init'
    @just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'init'

# 🌀 Quick feedback loop for development in Nix environment
tf-dev-nix MOD='default' EXAMPLE='basic':
    @just tf-ci-static-nix "{{MOD}}"
    @just tf-cmd-nix "{{MOD}}" 'init'
    @just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'init'
