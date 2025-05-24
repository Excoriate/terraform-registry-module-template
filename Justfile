# 🚀 Terraform Module Development Workflow: Automate setup, formatting, linting, and project management

# 🐚 Shell configuration
# Use bash with strict error handling to prevent silent failures
# -u: Treat unset variables as an error
# -e: Exit immediately if a command exits with a non-zero status
set shell := ["bash", "-uce"]
set dotenv-load

# Avoid reporting traces to Dagger
# TODO: Uncomment if traces aren't needed.
# export NOTHANKS := "1"

# 🎯 Default task: Display available recipes when no specific task is specified
default: help

# 📦 Variables for project directories
TESTS_DIR := 'tests'
MODULES_DIR := 'modules'
EXAMPLES_DIR := 'examples'
FIXTURES_DIR := 'fixtures'

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

# 🔍 Check if a module is a Terraform module
is-tf-module MOD='default':
    @echo "🔍 Checking if module: {{MODULES_DIR}}/{{MOD}} is a Terraform module..."
    @if [ -z "$(find "{{MODULES_DIR}}/{{MOD}}" -type f -name '*.tf')" ]; then \
        echo "❌ No Terraform files found in module: {{MODULES_DIR}}/{{MOD}}"; \
        exit 1; \
    fi

# 🧹 Remove Terraform and Terragrunt cache directories to reset project state
clean-tf:
    @echo "🗑️ Cleaning Terraform and Terragrunt cache directories across the entire repository..."
    find . -type d -name ".terraform" -exec rm -rf {} +; \
    find . -type d -name ".terragrunt-cache" -exec rm -rf {} +; \
    find . -type f -name "*.tfstate" -exec rm -f {} +; \
    find . -type f -name "*.tfstate.backup" -exec rm -f {} +; \
    echo "✅ Cleanup complete!"

# 🧹 Remove Terraform and Terragrunt cache directories for a specific module
clean-tf-mod MOD='default': (is-tf-module MOD)
    @echo "🗑️ Cleaning Terraform and Terragrunt cache directories for module: {{MOD}}..."
    @echo "🔍 Found module: {{MODULES_DIR}}/{{MOD}}"
    @echo "📂 Listing directories and files in module: {{MODULES_DIR}}/{{MOD}}"
    @ls -R "{{MODULES_DIR}}/{{MOD}}"
    find "{{MODULES_DIR}}/{{MOD}}" -type d -name ".terraform" -exec rm -rf {} +; \
    find "{{MODULES_DIR}}/{{MOD}}" -type d -name ".terragrunt-cache" -exec rm -rf {} +; \
    find "{{MODULES_DIR}}/{{MOD}}" -type f -name "*.tfstate" -exec rm -f {} +; \
    find "{{MODULES_DIR}}/{{MOD}}" -type f -name "*.tfstate.backup" -exec rm -f {} +; \
    echo "✅ Cleanup complete!"

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

# 🐹 Comprehensive CI checks for Go files in Nix environment
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

# 🌿 Format all Terraform files across modules, examples, and tests directories
tf-format-all:
    @echo "🌿 Formatting all Terraform files across the repository..."
    @echo "📂 Scanning directories: modules/, examples/, tests/"

    @echo "\n🔍 Formatting files in modules/"
    @pushd modules > /dev/null && \
    find . -type f \( -name "*.tf" -o -name "*.tfvars" \) | sort | while read -r file; do \
        echo "   📄 Processing: $file"; \
    done && \
    terraform fmt -recursive && \
    popd > /dev/null

    @echo "\n🔍 Formatting files in examples/"
    @pushd examples > /dev/null && \
    find . -type f \( -name "*.tf" -o -name "*.tfvars" \) | sort | while read -r file; do \
        echo "   📄 Processing: $file"; \
    done && \
    terraform fmt -recursive && \
    popd > /dev/null

    @echo "\n🔍 Formatting files in tests/"
    @pushd tests > /dev/null && \
    find . -type f \( -name "*.tf" -o -name "*.tfvars" \) | sort | while read -r file; do \
        echo "   📄 Processing: $file"; \
    done && \
    terraform fmt -recursive && \
    popd > /dev/null

    @echo "\n✅ All Terraform files have been formatted!"

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
tf-format-check MOD='':
    @echo "🌿 Discovering Terraform files..."
    @if [ -z "{{MOD}}" ]; then \
        find . -type f \( -name "*.tf" -o -name "*.tfvars" \) | sort | while read -r file; do \
            echo "📄 Found: $file"; \
        done; \
        unformatted_files=$(find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -check | tee /dev/tty); \
        if [ -n "$unformatted_files" ]; then \
            echo "❌ Some Terraform files are not properly formatted:"; \
            echo "$unformatted_files"; \
            exit 1; \
        else \
            echo "✅ All Terraform files are correctly formatted"; \
        fi; \
    else \
        echo "📂 Checking formatting for Terraform files in directory: {{MODULES_DIR}}/{{MOD}}"; \
        module_unformatted=$(cd "{{MODULES_DIR}}/{{MOD}}" && find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -check | tee /dev/tty); \
        example_unformatted=$(cd "{{EXAMPLES_DIR}}/{{MOD}}" && find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -check | tee /dev/tty); \
        \
        if [ -n "$module_unformatted" ] || [ -n "$example_unformatted" ]; then \
            echo "❌ Some Terraform files are not properly formatted:"; \
            if [ -n "$module_unformatted" ]; then \
                echo "📂 Unformatted files in module directory:"; \
                echo "$module_unformatted"; \
            fi; \
            if [ -n "$example_unformatted" ]; then \
                echo "📂 Unformatted files in example directory:"; \
                echo "$example_unformatted"; \
            fi; \
            exit 1; \
        else \
            echo "✅ All Terraform files are correctly formatted"; \
        fi; \
    fi

tf-format-check-nix MOD='':
    @echo "🌿 Discovering Terraform files in Nix environment..."
    @if [ -z "{{MOD}}" ]; then \
        find . -type f \( -name "*.tf" -o -name "*.tfvars" \) | sort | while read -r file; do \
            echo "📄 Found: $file"; \
        done; \
        unformatted_files=$(find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -check | tee /dev/tty); \
        if [ -n "$unformatted_files" ]; then \
            echo "❌ Some Terraform files are not properly formatted:"; \
            echo "$unformatted_files"; \
            exit 1; \
        else \
            echo "✅ All Terraform files are correctly formatted"; \
        fi; \
    else \
        echo "📂 Checking formatting for Terraform files in directory: {{MODULES_DIR}}/{{MOD}}"; \
        module_unformatted=$(cd "{{MODULES_DIR}}/{{MOD}}" && find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -check | tee /dev/tty); \
        example_unformatted=$(cd "{{EXAMPLES_DIR}}/{{MOD}}" && find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform fmt -check | tee /dev/tty); \
        \
        if [ -n "$module_unformatted" ] || [ -n "$example_unformatted" ]; then \
            echo "❌ Some Terraform files are not properly formatted:"; \
            if [ -n "$module_unformatted" ]; then \
                echo "📂 Unformatted files in module directory:"; \
                echo "$module_unformatted"; \
            fi; \
            if [ -n "$example_unformatted" ]; then \
                echo "📂 Unformatted files in example directory:"; \
                echo "$example_unformatted"; \
            fi; \
            exit 1; \
        else \
            echo "✅ All Terraform files are correctly formatted"; \
        fi; \
    fi


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
            tflint --init && \
            tflint --recursive && \
            cd - > /dev/null; \
        done \
    else \
        echo "🕵️ Linting module directory: {{MODULES_DIR}}/{{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && \
        tflint --init && \
        tflint --recursive && \
        cd - > /dev/null; \
        \
        echo "🕵️ Linting example subdirectories for module: {{MOD}}"; \
        for example_dir in $(find "{{EXAMPLES_DIR}}/{{MOD}}" -type f -name ".tflint.hcl" | xargs -I {} dirname {} | sort -u); do \
            echo "   📂 Linting example directory: $example_dir"; \
            cd "$example_dir" && \
            tflint --init && \
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
            nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'tflint --init && tflint --recursive' && \
            cd - > /dev/null; \
        done \
    else \
        echo "🕵️ Linting module directory: {{MODULES_DIR}}/{{MOD}}"; \
        cd "{{MODULES_DIR}}/{{MOD}}" && \
        nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'tflint --init && tflint --recursive' && \
        cd - > /dev/null; \
        \
        echo "🕵️ Linting example subdirectories for module: {{MOD}}"; \
        for example_dir in $(find "{{EXAMPLES_DIR}}/{{MOD}}" -type f -name ".tflint.hcl" | xargs -I {} dirname {} | sort -u); do \
            echo "   📂 Linting example directory: $example_dir"; \
            cd "$example_dir" && \
            nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c 'tflint --init && tflint --recursive' && \
            cd - > /dev/null; \
        done; \
    fi

tf-docs-generate MOD='':
    @echo "🔍 Generating Terraform module documentation..."
    @if [ -z "{{MOD}}" ]; then \
        for dir in $(find modules examples -type f -name ".terraform-docs.yml" | xargs -I {} dirname {} | sort -u); do \
            echo "📄 Attempting to generate docs for: $$dir"; \
            if [ -d "$$dir" ]; then \
                cd "$$dir" && \
                echo "   🔧 Current directory: $$(pwd)" && \
                terraform-docs markdown . --output-file README.md || \
                echo "   ❌ Documentation generation failed for $$dir"; \
                cd - > /dev/null; \
            else \
                echo "   ❌ Directory not found: $$dir"; \
            fi; \
        done; \
    else \
        if [ -d "modules/{{MOD}}" ] && [ -f "modules/{{MOD}}/.terraform-docs.yml" ]; then \
            echo "📄 Generating docs for module: modules/{{MOD}}"; \
            cd "modules/{{MOD}}" && \
            terraform-docs markdown . --output-file README.md || \
            echo "❌ Documentation generation failed for modules/{{MOD}}"; \
            cd - > /dev/null; \
        else \
            echo "   ⚠️  Skipping modules/{{MOD}} (no directory or .terraform-docs.yml)"; \
        fi; \
        if [ -d "examples/{{MOD}}" ]; then \
            for exdir in examples/{{MOD}}/*; do \
                if [ -d "$$exdir" ] && [ -f "$$exdir/.terraform-docs.yml" ]; then \
                    echo "📄 Generating docs for example: $$exdir"; \
                    cd "$$exdir" && \
                    terraform-docs markdown . --output-file README.md || \
                    echo "❌ Documentation generation failed for $$exdir"; \
                    cd - > /dev/null; \
                else \
                    echo "   ⚠️  Skipping $$exdir (no directory or .terraform-docs.yml)"; \
                fi; \
            done; \
        else \
            echo "   ⚠️  No examples found for module {{MOD}}"; \
        fi; \
    fi

# 📄 Generate Terraform module documentation in Nix development environment using terraform-docs
tf-docs-generate-nix MOD='':
    @echo "🔍 Generating Terraform module documentation (nix)..."
    @if [ -z "{{MOD}}" ]; then \
        for dir in $(find modules examples -type f -name ".terraform-docs.yml" | xargs -I {} dirname {} | sort -u); do \
            echo "📄 Attempting to generate docs for: $$dir"; \
            if [ -d "$$dir" ]; then \
                cd "$$dir" && \
                echo "   🔧 Current directory: $$(pwd)" && \
                nix run github:terraform-docs/terraform-docs -- markdown . --output-file README.md || \
                echo "   ❌ Documentation generation failed for $$dir"; \
                cd - > /dev/null; \
            else \
                echo "   ❌ Directory not found: $$dir"; \
            fi; \
        done; \
    else \
        if [ -d "modules/{{MOD}}" ] && [ -f "modules/{{MOD}}/.terraform-docs.yml" ]; then \
            echo "📄 Generating docs for module: modules/{{MOD}}"; \
            cd "modules/{{MOD}}" && \
            nix run github:terraform-docs/terraform-docs -- markdown . --output-file README.md || \
            echo "❌ Documentation generation failed for modules/{{MOD}}"; \
            cd - > /dev/null; \
        else \
            echo "   ⚠️  Skipping modules/{{MOD}} (no directory or .terraform-docs.yml)"; \
        fi; \
        if [ -d "examples/{{MOD}}" ]; then \
            for exdir in examples/{{MOD}}/*; do \
                if [ -d "$$exdir" ] && [ -f "$$exdir/.terraform-docs.yml" ]; then \
                    echo "📄 Generating docs for example: $$exdir"; \
                    cd "$$exdir" && \
                    nix run github:terraform-docs/terraform-docs -- markdown . --output-file README.md || \
                    echo "❌ Documentation generation failed for $$exdir"; \
                    cd - > /dev/null; \
                else \
                    echo "   ⚠️  Skipping $$exdir (no directory or .terraform-docs.yml)"; \
                fi; \
            done; \
        else \
            echo "   ⚠️  No examples found for module {{MOD}}"; \
        fi; \
    fi

# 📄 Validate Terraform modules locally using terraform validate
tf-validate MOD='': (tf-cmd MOD 'init -backend=false') (tf-cmd MOD 'validate')

# 📄 Validate Terraform modules in Nix development environment using terraform validate
tf-validate-nix MOD='': (tf-cmd-nix MOD 'init -backend=false') (tf-cmd-nix MOD 'validate')

# 📄 Run Terraform CI checks locally (only static, like 'fmt', 'lint', 'docs')
tf-ci-static MOD='': (tf-format-check MOD) (tf-lint MOD) (tf-docs-generate MOD) (tf-validate MOD)

# 📄 Run Terraform CI checks in Nix development environment
tf-ci-static-nix MOD='': (tf-format-check-nix MOD) (tf-lint-nix MOD) (tf-docs-generate-nix MOD) (tf-validate-nix MOD)

# 🌀 Quick feedback loop for development E.g: just tf-dev "default" "basic" "true"
tf-dev MOD='default' EXAMPLE='basic' FIXTURE='default.tfvars' CLEAN='false':
    @echo "🔄 Cleaning up resources for module: {{MOD}}, example: {{EXAMPLE}} (Clean: {{CLEAN}})"
    @if [ "{{CLEAN}}" = "true" ]; then \
        rm -rf "./modules/{{MOD}}/.terraform" && \
        rm -rf "./examples/{{MOD}}/{{EXAMPLE}}/.terraform" && \
        rm -f "./examples/{{MOD}}/{{EXAMPLE}}/.terraform.lock.hcl"; \
        echo "✅ Cleaned up resources for module: {{MOD}}, example: {{EXAMPLE}}"; \
    else \
        echo "🛑 No cleanup performed for module: {{MOD}}, example: {{EXAMPLE}}"; \
    fi;

    @echo "🔍 Running CI checks for module: {{MOD}}"
    @just tf-ci-static "{{MOD}}"

    @echo "🔍 Initializing module: {{MOD}}"
    @just tf-cmd "{{MOD}}" 'init'

    @echo "🔍 Initializing example: {{EXAMPLE}} for module: {{MOD}}"
    @just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'init'

    @echo "🔍 Validating example: {{EXAMPLE}} for module: {{MOD}}"
    @just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'validate'

    @if [ -f "./examples/{{MOD}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for planning"; \
        just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'plan -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}"'; \
    else \
        echo "📄 No fixture provided, running plan without it"; \
        just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'plan'; \
    fi

# 🌀 Quick feedback loop for development whic includes apply, and optionally destroy E.g: just tf-dev-apply "default" "basic" "default.tfvars" "true"
tf-dev-full MOD='default' EXAMPLE='basic' FIXTURE='default.tfvars' CLEAN='false': (tf-dev MOD EXAMPLE FIXTURE CLEAN)
    @echo "🚀 Running apply for module: {{MOD}}"
    @if [ -f "./examples/{{MOD}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for apply"; \
        just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'apply -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}" -auto-approve'; \
    else \
        echo "📄 No fixture provided, running apply without it"; \
        just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'apply -auto-approve'; \
    fi

    @echo "💣 Running destroy for module: {{MOD}}"
    @if [ -f "./examples/{{MOD}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for destroy"; \
        just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'destroy -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}" -auto-approve'; \
    else \
        echo "📄 No fixture provided, running destroy without it"; \
        just tf-exec "examples/{{MOD}}/{{EXAMPLE}}" 'destroy -auto-approve'; \
    fi

# 🌀 Quick feedback loop for development in Nix environment which includes apply and destroy E.g: just tf-dev-full-nix "default" "basic" "default.tfvars" "true"
tf-dev-full-nix MOD='default' EXAMPLE='basic' FIXTURE='default.tfvars' CLEAN='false': (tf-dev-full MOD EXAMPLE FIXTURE CLEAN)
    @echo "🚀 Running apply for module: {{MOD}}"
    @if [ -f "./examples/{{MOD}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for apply"; \
        just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'apply -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}" -auto-approve'; \
    else \
        echo "📄 No fixture provided, running apply without it"; \
        just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'apply -auto-approve'; \
    fi

    @echo "💣 Running destroy for module: {{MOD}}"
    @if [ -f "./examples/{{MOD}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for destroy"; \
        just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'destroy -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}" -auto-approve'; \
    else \
        echo "📄 No fixture provided, running destroy without it"; \
        just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'destroy -auto-approve'; \
    fi


# 🌀 Quick feedback loop for development in Nix environment
tf-dev-nix MOD='default' EXAMPLE='basic' FIXTURE='default.tfvars' CLEAN='false':
    @echo "🔄 Cleaning up resources for module: {{MOD}}, example: {{EXAMPLE}} (Clean: {{CLEAN}})"
    @if [ "{{CLEAN}}" = "true" ]; then \
        rm -rf "./modules/{{MOD}}/.terraform" && \
        rm -rf "./examples/{{MOD}}/{{EXAMPLE}}/.terraform" && \
        rm -f "./examples/{{MOD}}/{{EXAMPLE}}/.terraform.lock.hcl"; \
        echo "✅ Cleaned up resources for module: {{MOD}}, example: {{EXAMPLE}}"; \
    else \
        echo "🛑 No cleanup performed for module: {{MOD}}, example: {{EXAMPLE}}"; \
    fi;

    @echo "🔍 Running CI checks for module: {{MOD}}"
    @just tf-ci-static-nix "{{MOD}}"

    @echo "🔍 Initializing module: {{MOD}}"
    @just tf-cmd-nix "{{MOD}}" 'init'

    @echo "🔍 Initializing example: {{EXAMPLE}} for module: {{MOD}}"
    @just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'init'

    @echo "🔍 Validating example: {{EXAMPLE}} for module: {{MOD}}"
    @just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'validate'

    @if [ -f "./examples/{{MOD}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for planning"; \
        just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'plan -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}"'; \
    else \
        echo "📄 No fixture provided, running plan without it"; \
        just tf-exec-nix "examples/{{MOD}}/{{EXAMPLE}}" 'plan'; \
    fi

# 🧪 Run unit tests - parameters: TAGS (E.g. 'readonly' or 'integration'), MOD (module name), NOCACHE (true/false), TIMEOUT (E.g. '60s|5m|1h')
tf-test-unit TAGS='readonly' MOD='default' NOCACHE='true' TIMEOUT='60s':
    @echo "🧪 Running unit tests..."
    @echo "📋 Configuration:"
    @echo "   🏷️  Tags: unit,{{TAGS}}"
    @echo "   🔍 Module: {{MOD}}"
    @echo "   🔄 No Cache: {{NOCACHE}}"
    @echo "   ⏱️  Timeout: {{TIMEOUT}}"

    @if ! echo "{{TIMEOUT}}" | grep -qE '^[0-9]+[smh]$'; then \
        echo "❌ Invalid timeout format. Use format like '60s', '5m', or '1h'"; \
        exit 1; \
    fi

    @cd {{TESTS_DIR}} && \
    if [ -z "{{MOD}}" ] || [ "{{MOD}}" = "default" ]; then \
        echo "🔍 Running unit tests for module: default in path {{TESTS_DIR}}/modules/{{MOD}}/unit" && \
        echo "🧹 Cleaning up terraform state" && \
        find . -type d -name ".terraform" -exec rm -rf {} \; 2>/dev/null || true; \
        find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true; \
        go test \
            -v \
            -tags "unit,{{TAGS}}" \
            $(if [ "{{NOCACHE}}" = "true" ]; then echo "-count=1"; fi) \
            -timeout="{{TIMEOUT}}" \
            ./modules/default/unit/...; \
    else \
        if [ -d "./modules/{{MOD}}/unit" ]; then \
            echo "🔍 Running unit tests for module: {{MOD}}" && \
            echo "🧹 Cleaning up terraform state" && \
            find "./modules/{{MOD}}/unit" -type d -name ".terraform" -exec rm -rf {} \; 2>/dev/null || true; \
            find "./modules/{{MOD}}/unit" -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true; \
            go test \
                -v \
                -tags "unit,{{TAGS}}" \
                $(if [ "{{NOCACHE}}" = "true" ]; then echo "-count=1"; fi) \
                -timeout="{{TIMEOUT}}" \
                "./modules/{{MOD}}/unit/..."; \
        else \
            echo "❌ Unit test directory not found: ./modules/{{MOD}}/unit"; \
            exit 1; \
        fi; \
    fi

# 🧪 Run unit tests in Nix environment - parameters: TAGS (E.g. 'readonly' or 'integration'), MOD (module name), NOCACHE (true/false), TIMEOUT (E.g. '60s|5m|1h')
tf-test-unit-nix TAGS='readonly' MOD='default' NOCACHE='true' TIMEOUT='60s':
    @echo "🧪 Running unit tests in Nix environment..."
    @echo "📋 Configuration:"
    @echo "   🏷️  Tags: unit,{{TAGS}}"
    @echo "   🔍 Module: {{MOD}}"
    @echo "   🔄 No Cache: {{NOCACHE}}"
    @echo "   ⏱️  Timeout: {{TIMEOUT}}"

    @if ! echo "{{TIMEOUT}}" | grep -qE '^[0-9]+[smh]$'; then \
        echo "❌ Invalid timeout format. Use format like '60s', '5m', or '1h'"; \
        exit 1; \
    fi

    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c "cd {{TESTS_DIR}} && \
    if [ -z '{{MOD}}' ] || [ '{{MOD}}' = 'default' ]; then \
        echo '🔍 Running unit tests for module: default' && \
        find . -type d -name '.terraform' -exec rm -rf {} \; 2>/dev/null || true; \
        find . -type f -name '.terraform.lock.hcl' -delete 2>/dev/null || true; \
        go test \
            -v \
            -tags 'unit,{{TAGS}}' \
            $(if [ '{{NOCACHE}}' = 'true' ]; then echo '-count=1'; fi) \
            -timeout='{{TIMEOUT}}' \
            ./modules/default/unit/...; \
    else \
        if [ -d './modules/{{MOD}}/unit' ]; then \
            echo '🔍 Running unit tests for module: {{MOD}}' && \
            find './modules/{{MOD}}/unit' -type d -name '.terraform' -exec rm -rf {} \; 2>/dev/null || true; \
            find './modules/{{MOD}}/unit' -type f -name '.terraform.lock.hcl' -delete 2>/dev/null || true; \
            go test \
                -v \
                -tags 'unit,{{TAGS}}' \
                $(if [ '{{NOCACHE}}' = 'true' ]; then echo '-count=1'; fi) \
                -timeout='{{TIMEOUT}}' \
                './modules/{{MOD}}/unit/...'; \
        else \
            echo '❌ Unit test directory not found: ./modules/{{MOD}}/unit'; \
            exit 1; \
        fi; \
    fi"

# 🧪 Run examples tests - parameters: TAGS (E.g. 'readonly' or 'integration'), MOD (module name), NOCACHE (true/false), TIMEOUT (E.g. '60s|5m|1h')
tf-test-examples TAGS='readonly' MOD='default' NOCACHE='true' TIMEOUT='60s':
    @echo "🧪 Running example tests..."
    @echo "📋 Configuration:"
    @echo "   🏷️  Tags: examples,{{TAGS}}"
    @echo "   🔍 Module: {{MOD}}"
    @echo "   🔄 No Cache: {{NOCACHE}}"
    @echo "   ⏱️  Timeout: {{TIMEOUT}}"

    @if ! echo "{{TIMEOUT}}" | grep -qE '^[0-9]+[smh]$'; then \
        echo "❌ Invalid timeout format. Use format like '60s', '5m', or '1h'"; \
        exit 1; \
    fi

    @cd {{TESTS_DIR}} && \
    if [ -z "{{MOD}}" ] || [ "{{MOD}}" = "default" ]; then \
        echo "🔍 Running examples tests for module: default in path {{TESTS_DIR}}/modules/{{MOD}}/examples" && \
        echo "🧹 Cleaning up terraform state" && \
        find . -type d -name ".terraform" -exec rm -rf {} \; 2>/dev/null || true; \
        find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true; \
        go test \
            -v \
            -tags "examples,{{TAGS}}" \
            $(if [ "{{NOCACHE}}" = "true" ]; then echo "-count=1"; fi) \
            -timeout="{{TIMEOUT}}" \
            ./modules/default/examples/...; \
    else \
        if [ -d "./modules/{{MOD}}/examples" ]; then \
            echo "🔍 Running examples tests for module: {{MOD}}" && \
            echo "🧹 Cleaning up terraform state" && \
            find "./modules/{{MOD}}/examples" -type d -name ".terraform" -exec rm -rf {} \; 2>/dev/null || true; \
            find "./modules/{{MOD}}/examples" -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true; \
            go test \
                -v \
                -tags "examples,{{TAGS}}" \
                $(if [ "{{NOCACHE}}" = "true" ]; then echo "-count=1"; fi) \
                -timeout="{{TIMEOUT}}" \
                "./modules/{{MOD}}/examples/..."; \
        else \
            echo "❌ Examples test directory not found: ./modules/{{MOD}}/examples"; \
            exit 1; \
        fi; \
    fi

# 🧪 Run examples tests in Nix environment - parameters: TAGS (E.g. 'readonly' or 'integration'), MOD (module name), NOCACHE (true/false), TIMEOUT (E.g. '60s|5m|1h')
tf-test-examples-nix TAGS='readonly' MOD='default' NOCACHE='true' TIMEOUT='60s':
    @echo "🧪 Running example tests in Nix environment..."
    @echo "📋 Configuration:"
    @echo "   🏷️  Tags: examples,{{TAGS}}"
    @echo "   🔍 Module: {{MOD}}"
    @echo "   🔄 No Cache: {{NOCACHE}}"
    @echo "   ⏱️  Timeout: {{TIMEOUT}}"

    @if ! echo "{{TIMEOUT}}" | grep -qE '^[0-9]+[smh]$'; then \
        echo "❌ Invalid timeout format. Use format like '60s', '5m', or '1h'"; \
        exit 1; \
    fi

    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c "cd {{TESTS_DIR}} && \
    if [ -z '{{MOD}}' ] || [ '{{MOD}}' = 'default' ]; then \
        echo '🔍 Running examples tests for module: default' && \
        find . -type d -name '.terraform' -exec rm -rf {} \; 2>/dev/null || true; \
        find . -type f -name '.terraform.lock.hcl' -delete 2>/dev/null || true; \
        go test \
            -v \
            -tags 'examples,{{TAGS}}' \
            $(if [ '{{NOCACHE}}' = 'true' ]; then echo '-count=1'; fi) \
            -timeout='{{TIMEOUT}}' \
            ./modules/default/examples/...; \
    else \
        if [ -d './modules/{{MOD}}/examples' ]; then \
            echo '🔍 Running examples tests for module: {{MOD}}' && \
            find './modules/{{MOD}}/examples' -type d -name '.terraform' -exec rm -rf {} \; 2>/dev/null || true; \
            find './modules/{{MOD}}/examples' -type f -name '.terraform.lock.hcl' -delete 2>/dev/null || true; \
            go test \
                -v \
                -tags 'examples,{{TAGS}}' \
                $(if [ '{{NOCACHE}}' = 'true' ]; then echo '-count=1'; fi) \
                -timeout='{{TIMEOUT}}' \
                './modules/{{MOD}}/examples/...'; \
        else \
            echo '❌ Examples test directory not found: ./modules/{{MOD}}/examples'; \
            exit 1; \
        fi; \
    fi"


# 🔨 Build the Dagger pipeline
[working-directory:'pipeline/infra']
pipeline-infra-build:
    @echo "🔨 Initializing Dagger development environment"
    @dagger develop
    @echo "📋 Building Dagger pipeline"
    @dagger functions

# 🔨 Help for Dagger job
[working-directory:'pipeline/infra']
pipeline-job-help fn: (pipeline-infra-build)
    @echo "🔨 Help for Dagger job: {{fn}}"
    @dagger call {{fn}} --help

# 🔨 Open an interactive development shell for the Infra pipeline
[working-directory:'pipeline/infra']
pipeline-infra-shell args="": (pipeline-infra-build)
    @echo "🚀 Launching interactive terminal"
    @dagger call open-terminal {{args}}

# 🔨 Execute a Dagger job
[working-directory:'pipeline/infra']
pipeline-job-exec mod="default" command="init" args="": (pipeline-infra-build)
    @echo "🚀 Executing job: {{command}} with arguments: {{args}}"
    @dagger --use-hashicorp-image=true call job-terraform-exec \
       --command="{{command}}" \
       --tf-module-path="{{mod}}" \
       --arguments="{{args}}" \
       --aws-access-key-id=env:AWS_ACCESS_KEY_ID \
       --aws-secret-access-key=env:AWS_SECRET_ACCESS_KEY \
       --aws-session-token=env:AWS_SESSION_TOKEN \
       --aws-region=env:AWS_REGION \
       --load-dot-env-file=true \
       --no-cache=true \
       --git-ssh $SSH_AUTH_SOCK

# 🔨 Validate Terraform modules for best practices and security
[working-directory:'pipeline/infra']
pipeline-infra-tf-modules-static-check args="": (pipeline-infra-build)
    @echo " Analyzing Terraform modules for security and best practices"
    @echo "⚡ Running static analysis checks"
    @dagger call job-tf-modules-static-check {{args}}
    @echo "✅ Static analysis completed successfully"

# 🔨 Test Terraform modules against multiple provider versions
[working-directory:'pipeline/infra']
pipeline-infra-tf-modules-versions args="": (pipeline-infra-build)
    @echo " Testing module compatibility across provider versions"
    @echo "⚡ Running version compatibility checks"
    @dagger call job-tf-modules-compatibility-check {{args}}
    @echo "✅ Version compatibility testing completed"

# 🔨 Run comprehensive CI checks for Terraform modules
pipeline-infra-tf-ci args="": (pipeline-infra-tf-modules-static-check) (pipeline-infra-tf-modules-versions)