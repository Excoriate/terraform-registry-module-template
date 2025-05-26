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
TESTS_DIR := 'tests/modules'
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
tf-format:
    @echo "🎨 Formatting Terraform files in current directory..."
    @./scripts/utilities/format.sh --terraform

# 🌿 Format all Terraform files across modules, examples, and tests directories
tf-format-all:
    @echo "🎨 Formatting all Terraform files across repository..."
    @./scripts/utilities/format.sh --terraform --tf-all-dirs

# 🌿 Format Terraform files for a specific module (both module and example directories)
tf-format-module MODULE:
    @echo "🎨 Formatting Terraform files for module: {{MODULE}}"
    @./scripts/utilities/format.sh --terraform --tf-module {{MODULE}}

# 🔍 Check Terraform file formatting without modifying files
tf-format-check MOD='':
    @echo "🔍 Checking Terraform file formatting..."
    @if [ -z "{{MOD}}" ]; then \
        ./scripts/utilities/format.sh --terraform --tf-check; \
    else \
        ./scripts/utilities/format.sh --terraform --tf-check --tf-module {{MOD}}; \
    fi

# 🔍 Check Terraform file formatting for all directories
tf-format-check-all:
    @echo "🔍 Checking Terraform file formatting across all directories..."
    @./scripts/utilities/format.sh --terraform --tf-check --tf-all-dirs

# 🔍 Check Terraform file formatting for a specific module
tf-format-check-module MODULE:
    @echo "🔍 Checking Terraform file formatting for module: {{MODULE}}"
    @./scripts/utilities/format.sh --terraform --tf-check --tf-module {{MODULE}}

# 🔍 Check Terraform file formatting without modifying files (Nix environment)
tf-format-check-nix MOD='':
    @echo "🔍 Checking Terraform file formatting in Nix environment..."
    @if [ -z "{{MOD}}" ]; then \
        nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --terraform --tf-check; \
    else \
        nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command ./scripts/utilities/format.sh --terraform --tf-check --tf-module {{MOD}}; \
    fi

# 🔍 Discover and list all Terraform files in the repository
tf-discover:
    @echo "🔍 Discovering Terraform files..."
    @./scripts/utilities/format.sh --terraform --tf-discover

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
tf-exec-mod MODULE='.' CMDS='--help':
    @echo "🏗️ Running Terraform command:"
    @echo "👨🏻‍💻 Command: terraform {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{MODULES_DIR}}/{{MODULE}})"
    @cd "{{MODULES_DIR}}/{{MODULE}}" && terraform {{CMDS}}

# 🌿 Run Terraform commands in Nix development environment with flexible module and command selection
tf-exec-mod-cmd-nix MODULE='.' CMDS='--help':
    @echo "🏗️ Running Terraform command in Nix environment:"
    @echo "👨🏻‍💻 Command: terraform {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{MODULES_DIR}}/{{MODULE}})"
    @cd "{{MODULES_DIR}}/{{MODULE}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command terraform {{CMDS}}

# 🌿 Run OpenTofu commands locally with flexible module and command selection
tofu-exec-mod MODULE='.' CMDS='--help':
    @echo "🏗️ Running OpenTofu command:"
    @echo "👨🏻‍💻 Command: tofu {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{MODULES_DIR}}/{{MODULE}})"
    @cd "{{MODULES_DIR}}/{{MODULE}}" && tofu {{CMDS}}

# 🌿 Run OpenTofu commands in Nix development environment with flexible module and command selection
tofu-exec-mod-cmd-nix MODULE='.' CMDS='--help':
    @echo "🏗️ Running OpenTofu command in Nix environment:"
    @echo "👨🏻‍💻 Command: tofu {{CMDS}}"
    @echo "📂 Working directory: $(realpath {{MODULES_DIR}}/{{MODULE}})"
    @cd "{{MODULES_DIR}}/{{MODULE}}" && nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command tofu {{CMDS}}

# 🔍 Run TFLint on Terraform files to check for issues and best practices
tf-lint MODULE='':
    @echo "🔍 Running TFLint on Terraform files..."
    @if [ -z "{{MODULE}}" ]; then \
        ./scripts/utilities/tflint.sh; \
    else \
        ./scripts/utilities/tflint.sh --module {{MODULE}}; \
    fi

# 🔍 Run TFLint on Terraform files using Nix environment
tf-lint-nix MODULE='':
    @echo "🔍 Running TFLint on Terraform files in Nix environment..."
    @if [ -z "{{MODULE}}" ]; then \
        ./scripts/utilities/tflint.sh --nix; \
    else \
        ./scripts/utilities/tflint.sh --module {{MODULE}} --nix; \
    fi

# 📄 Generate Terraform documentation using terraform-docs
tf-docs-generate MODULE='':
    @echo "📄 Generating Terraform documentation..."
    @if [ -z "{{MODULE}}" ]; then \
        ./scripts/utilities/tfdocs.sh; \
    else \
        ./scripts/utilities/tfdocs.sh --module {{MODULE}}; \
    fi

# 📄 Generate Terraform documentation using terraform-docs in Nix environment
tf-docs-generate-nix MODULE='':
    @echo "📄 Generating Terraform documentation in Nix environment..."
    @if [ -z "{{MODULE}}" ]; then \
        ./scripts/utilities/tfdocs.sh --nix; \
    else \
        ./scripts/utilities/tfdocs.sh --module {{MODULE}} --nix; \
    fi

# 📄 Validate Terraform modules locally using terraform validate
tf-validate MODULE='': (tf-exec-mod MODULE 'init -backend=false') (tf-exec-mod MODULE 'validate')

# 📄 Validate Terraform modules in Nix development environment using terraform validate
tf-validate-nix MODULE='': (tf-exec-mod-cmd-nix MODULE 'init -backend=false') (tf-exec-mod-cmd-nix MODULE 'validate')

# 📄 Run Terraform CI checks locally (only static, like 'fmt', 'lint', 'docs')
tf-ci-static MODULE='': (tf-format-check MODULE) (tf-lint MODULE) (tf-docs-generate MODULE) (tf-validate MODULE)

# 📄 Run Terraform CI checks in Nix development environment
tf-ci-static-nix MODULE='': (tf-format-check-nix MODULE) (tf-lint-nix MODULE) (tf-docs-generate-nix MODULE) (tf-validate-nix MODULE)

# 🌀 Quick feedback loop for development E.g: just tf-dev "default" "basic" "true"
tf-dev MODULE='default' EXAMPLE='basic' FIXTURE='default.tfvars' CLEAN='false':
    @echo "🔄 Cleaning up resources for module: {{MODULE}}, example: {{EXAMPLE}} (Clean: {{CLEAN}})"
    @if [ "{{CLEAN}}" = "true" ]; then \
        rm -rf "./modules/{{MODULE}}/.terraform" && \
        rm -rf "./examples/{{MODULE}}/{{EXAMPLE}}/.terraform" && \
        rm -f "./examples/{{MODULE}}/{{EXAMPLE}}/.terraform.lock.hcl"; \
        echo "✅ Cleaned up resources for module: {{MODULE}}, example: {{EXAMPLE}}"; \
    else \
        echo "🛑 No cleanup performed for module: {{MODULE}}, example: {{EXAMPLE}}"; \
    fi;

    @echo "🔍 Running CI checks for module: {{MODULE}}"
    @just tf-ci-static "{{MODULE}}"

    @echo "🔍 Initializing module: {{MODULE}}"
    @just tf-exec-mod "{{MODULE}}" 'init'

    @echo "🔍 Initializing example: {{EXAMPLE}} for module: {{MODULE}}"
    @just tf-exec "examples/{{MODULE}}/{{EXAMPLE}}" 'init'

    @echo "🔍 Validating example: {{EXAMPLE}} for module: {{MODULE}}"
    @just tf-exec "examples/{{MODULE}}/{{EXAMPLE}}" 'validate'

    @if [ -f "./examples/{{MODULE}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for planning"; \
        just tf-exec "examples/{{MODULE}}/{{EXAMPLE}}" 'plan -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}"'; \
    else \
        echo "📄 No fixture provided, running plan without it"; \
        just tf-exec "examples/{{MODULE}}/{{EXAMPLE}}" 'plan'; \
    fi

# 🌀 Quick feedback loop for development whic includes apply, and optionally destroy E.g: just tf-dev-apply "default" "basic" "default.tfvars" "true"
tf-dev-full MODULE='default' EXAMPLE='basic' FIXTURE='default.tfvars' CLEAN='false': (tf-dev MODULE EXAMPLE FIXTURE CLEAN)
    @echo "🚀 Running apply for module: {{MODULE}}"
    @if [ -f "./examples/{{MODULE}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for apply"; \
        just tf-exec "examples/{{MODULE}}/{{EXAMPLE}}" 'apply -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}" -auto-approve'; \
    else \
        echo "📄 No fixture provided, running apply without it"; \
        just tf-exec "examples/{{MODULE}}/{{EXAMPLE}}" 'apply -auto-approve'; \
    fi

    @echo "💣 Running destroy for module: {{MODULE}}"
    @if [ -f "./examples/{{MODULE}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for destroy"; \
        just tf-exec "examples/{{MODULE}}/{{EXAMPLE}}" 'destroy -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}" -auto-approve'; \
    else \
        echo "📄 No fixture provided, running destroy without it"; \
        just tf-exec "examples/{{MODULE}}/{{EXAMPLE}}" 'destroy -auto-approve'; \
    fi

# 🌀 Quick feedback loop for development in Nix environment which includes apply and destroy E.g: just tf-dev-full-nix "default" "basic" "default.tfvars" "true"
tf-dev-full-nix MODULE='default' EXAMPLE='basic' FIXTURE='default.tfvars' CLEAN='false': (tf-dev-full MODULE EXAMPLE FIXTURE CLEAN)
    @echo "🚀 Running apply for module: {{MODULE}}"
    @if [ -f "./examples/{{MODULE}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for apply"; \
        just tf-exec-nix "examples/{{MODULE}}/{{EXAMPLE}}" 'apply -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}" -auto-approve'; \
    else \
        echo "📄 No fixture provided, running apply without it"; \
        just tf-exec-nix "examples/{{MODULE}}/{{EXAMPLE}}" 'apply -auto-approve'; \
    fi

    @echo "💣 Running destroy for module: {{MODULE}}"
    @if [ -f "./examples/{{MODULE}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for destroy"; \
        just tf-exec-nix "examples/{{MODULE}}/{{EXAMPLE}}" 'destroy -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}" -auto-approve'; \
    else \
        echo "📄 No fixture provided, running destroy without it"; \
        just tf-exec-nix "examples/{{MODULE}}/{{EXAMPLE}}" 'destroy -auto-approve'; \
    fi


# 🌀 Quick feedback loop for development in Nix environment
tf-dev-nix MODULE='default' EXAMPLE='basic' FIXTURE='default.tfvars' CLEAN='false':
    @echo "🔄 Cleaning up resources for module: {{MODULE}}, example: {{EXAMPLE}} (Clean: {{CLEAN}})"
    @if [ "{{CLEAN}}" = "true" ]; then \
        rm -rf "./modules/{{MODULE}}/.terraform" && \
        rm -rf "./examples/{{MODULE}}/{{EXAMPLE}}/.terraform" && \
        rm -f "./examples/{{MODULE}}/{{EXAMPLE}}/.terraform.lock.hcl"; \
        echo "✅ Cleaned up resources for module: {{MODULE}}, example: {{EXAMPLE}}"; \
    else \
        echo "🛑 No cleanup performed for module: {{MODULE}}, example: {{EXAMPLE}}"; \
    fi;

    @echo "🔍 Running CI checks for module: {{MODULE}}"
    @just tf-ci-static-nix "{{MODULE}}"

    @echo "🔍 Initializing module: {{MODULE}}"
    @just tf-cmd-nix "{{MODULE}}" 'init'

    @echo "🔍 Initializing example: {{EXAMPLE}} for module: {{MODULE}}"
    @just tf-exec-nix "examples/{{MODULE}}/{{EXAMPLE}}" 'init'

    @echo "🔍 Validating example: {{EXAMPLE}} for module: {{MODULE}}"
    @just tf-exec-nix "examples/{{MODULE}}/{{EXAMPLE}}" 'validate'

    @if [ -f "./examples/{{MODULE}}/{{EXAMPLE}}/{{FIXTURES_DIR}}/{{FIXTURE}}" ]; then \
        echo "📄 Using fixture: {{FIXTURES_DIR}}/{{FIXTURE}} for planning"; \
        just tf-exec-nix "examples/{{MODULE}}/{{EXAMPLE}}" 'plan -var-file="{{FIXTURES_DIR}}/{{FIXTURE}}"'; \
    else \
        echo "📄 No fixture provided, running plan without it"; \
        just tf-exec-nix "examples/{{MODULE}}/{{EXAMPLE}}" 'plan'; \
    fi

# 🧪 Run unit tests - parameters: TAGS (E.g. 'readonly' or 'integration'), MOD (module name), NOCACHE (true/false), TIMEOUT (E.g. '60s|5m|1h')
tf-test-unit TAGS='readonly' MODULE='default' NOCACHE='true' TIMEOUT='60s':
    @echo "🧪 Running unit tests..."
    @echo "📋 Configuration:"
    @echo "   🏷️  Tags: unit,{{TAGS}}"
    @echo "   🔍 Module: {{MODULE}}"
    @echo "   🔄 No Cache: {{NOCACHE}}"
    @echo "   ⏱️  Timeout: {{TIMEOUT}}"

    @if ! echo "{{TIMEOUT}}" | grep -qE '^[0-9]+[smh]$'; then \
        echo "❌ Invalid timeout format. Use format like '60s', '5m', or '1h'"; \
        exit 1; \
    fi

    @cd {{TESTS_DIR}} && \
    if [ -z "{{MODULE}}" ] || [ "{{MODULE}}" = "default" ]; then \
        echo "🔍 Running unit tests for module: default in path {{TESTS_DIR}}/modules/{{MODULE}}/unit" && \
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
        if [ -d "./modules/{{MODULE}}/unit" ]; then \
            echo "🔍 Running unit tests for module: {{MODULE}}" && \
            echo "🧹 Cleaning up terraform state" && \
            find "./modules/{{MODULE}}/unit" -type d -name ".terraform" -exec rm -rf {} \; 2>/dev/null || true; \
            find "./modules/{{MODULE}}/unit" -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true; \
            go test \
                -v \
                -tags "unit,{{TAGS}}" \
                $(if [ "{{NOCACHE}}" = "true" ]; then echo "-count=1"; fi) \
                -timeout="{{TIMEOUT}}" \
                "./modules/{{MODULE}}/unit/..."; \
        else \
            echo "❌ Unit test directory not found: ./modules/{{MODULE}}/unit"; \
            exit 1; \
        fi; \
    fi

# 🧪 Run unit tests in Nix environment - parameters: TAGS (E.g. 'readonly' or 'integration'), MOD (module name), NOCACHE (true/false), TIMEOUT (E.g. '60s|5m|1h')
tf-test-unit-nix TAGS='readonly' MODULE='default' NOCACHE='true' TIMEOUT='60s':
    @echo "🧪 Running unit tests in Nix environment..."
    @echo "📋 Configuration:"
    @echo "   🏷️  Tags: unit,{{TAGS}}"
    @echo "   🔍 Module: {{MODULE}}"
    @echo "   🔄 No Cache: {{NOCACHE}}"
    @echo "   ⏱️  Timeout: {{TIMEOUT}}"

    @if ! echo "{{TIMEOUT}}" | grep -qE '^[0-9]+[smh]$'; then \
        echo "❌ Invalid timeout format. Use format like '60s', '5m', or '1h'"; \
        exit 1; \
    fi

    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c "cd {{TESTS_DIR}} && \
    if [ -z '{{MODULE}}' ] || [ '{{MODULE}}' = 'default' ]; then \
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
        if [ -d './modules/{{MODULE}}/unit' ]; then \
            echo '🔍 Running unit tests for module: {{MODULE}}' && \
            find './modules/{{MODULE}}/unit' -type d -name '.terraform' -exec rm -rf {} \; 2>/dev/null || true; \
            find './modules/{{MODULE}}/unit' -type f -name '.terraform.lock.hcl' -delete 2>/dev/null || true; \
            go test \
                -v \
                -tags 'unit,{{TAGS}}' \
                $(if [ '{{NOCACHE}}' = 'true' ]; then echo '-count=1'; fi) \
                -timeout='{{TIMEOUT}}' \
                './modules/{{MODULE}}/unit/...'; \
        else \
            echo '❌ Unit test directory not found: ./modules/{{MODULE}}/unit'; \
            exit 1; \
        fi; \
    fi"

# 🧪 Run examples tests - parameters: TAGS (E.g. 'readonly' or 'integration'), MOD (module name), NOCACHE (true/false), TIMEOUT (E.g. '60s|5m|1h')
tf-test-examples TAGS='readonly' MODULE='default' NOCACHE='true' TIMEOUT='60s':
    @echo "🧪 Running example tests..."
    @echo "📋 Configuration:"
    @echo "   🏷️  Tags: examples,{{TAGS}}"
    @echo "   🔍 Module: {{MODULE}}"
    @echo "   🔄 No Cache: {{NOCACHE}}"
    @echo "   ⏱️  Timeout: {{TIMEOUT}}"

    @if ! echo "{{TIMEOUT}}" | grep -qE '^[0-9]+[smh]$'; then \
        echo "❌ Invalid timeout format. Use format like '60s', '5m', or '1h'"; \
        exit 1; \
    fi

    @cd {{TESTS_DIR}} && \
    if [ -z "{{MODULE}}" ] || [ "{{MODULE}}" = "default" ]; then \
        echo "🔍 Running examples tests for module: default in path {{TESTS_DIR}}/modules/{{MODULE}}/examples" && \
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
        if [ -d "./modules/{{MODULE}}/examples" ]; then \
            echo "🔍 Running examples tests for module: {{MODULE}}" && \
            echo "🧹 Cleaning up terraform state" && \
            find "./modules/{{MODULE}}/examples" -type d -name ".terraform" -exec rm -rf {} \; 2>/dev/null || true; \
            find "./modules/{{MODULE}}/examples" -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true; \
            go test \
                -v \
                -tags "examples,{{TAGS}}" \
                $(if [ "{{NOCACHE}}" = "true" ]; then echo "-count=1"; fi) \
                -timeout="{{TIMEOUT}}" \
                "./modules/{{MODULE}}/examples/..."; \
        else \
            echo "❌ Examples test directory not found: ./modules/{{MODULE}}/examples"; \
            exit 1; \
        fi; \
    fi

# 🧪 Run examples tests in Nix environment - parameters: TAGS (E.g. 'readonly' or 'integration'), MOD (module name), NOCACHE (true/false), TIMEOUT (E.g. '60s|5m|1h')
tf-test-examples-nix TAGS='readonly' MODULE='default' NOCACHE='true' TIMEOUT='60s':
    @echo "🧪 Running example tests in Nix environment..."
    @echo "📋 Configuration:"
    @echo "   🏷️  Tags: examples,{{TAGS}}"
    @echo "   🔍 Module: {{MODULE}}"
    @echo "   🔄 No Cache: {{NOCACHE}}"
    @echo "   ⏱️  Timeout: {{TIMEOUT}}"

    @if ! echo "{{TIMEOUT}}" | grep -qE '^[0-9]+[smh]$'; then \
        echo "❌ Invalid timeout format. Use format like '60s', '5m', or '1h'"; \
        exit 1; \
    fi

    @nix develop . --impure --extra-experimental-features nix-command --extra-experimental-features flakes --command bash -c "cd {{TESTS_DIR}} && \
    if [ -z '{{MODULE}}' ] || [ '{{MODULE}}' = 'default' ]; then \
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
        if [ -d './modules/{{MODULE}}/examples' ]; then \
            echo '🔍 Running examples tests for module: {{MODULE}}' && \
            find './modules/{{MODULE}}/examples' -type d -name '.terraform' -exec rm -rf {} \; 2>/dev/null || true; \
            find './modules/{{MODULE}}/examples' -type f -name '.terraform.lock.hcl' -delete 2>/dev/null || true; \
            go test \
                -v \
                -tags 'examples,{{TAGS}}' \
                $(if [ '{{NOCACHE}}' = 'true' ]; then echo '-count=1'; fi) \
                -timeout='{{TIMEOUT}}' \
                './modules/{{MODULE}}/examples/...'; \
        else \
            echo '❌ Examples test directory not found: ./modules/{{MODULE}}/examples'; \
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

# 🔨 Execute a Dagger job with a specified command and arguments
[working-directory:'pipeline/infra']
pipeline-job-exec mod="default" command="init" args="": (pipeline-infra-build)
    @echo "🚀 Executing job: {{command}} with arguments: {{args}}"
    @dagger --use-hashicorp-image=true call job-terraform-exec \
       --command="{{command}}" \
       --tf-module-path="{{mod}}" \
       --arguments="{{args}}" \
       --load-dot-env-file=true \
       --no-cache=true \
       --tflint-version="0.58.0" \
       --terraform-docs-version="0.20.0" \
       --git-ssh $SSH_AUTH_SOCK

# 🔨 Perform static analysis on Terraform modules for security and best practices
[working-directory:'pipeline/infra']
pipeline-action-terraform-static-analysis MODULE="default" args="": (pipeline-infra-build)
    @echo " Analyzing Terraform modules for security and best practices"
    @echo "⚡ Running static analysis checks"
    @dagger --use-hashicorp-image=true call action-terraform-static-analysis \
       --tf-module-path="{{MODULE}}" \
       --load-dot-env-file=true \
       --no-cache=true \
       --git-ssh $SSH_AUTH_SOCK
    @echo "✅ Static analysis completed successfully"

# 🔨 Verify compatibility of Terraform modules across different provider versions
[working-directory:'pipeline/infra']
pipeline-action-terraform-version-compatibility-verification MODULE="default": (pipeline-infra-build)
    @echo " Testing module compatibility across provider versions"
    @echo "⚡ Running version compatibility checks"
    @dagger --use-hashicorp-image=true call action-terraform-version-compatibility-verification \
       --tf-module-path="{{MODULE}}" \
       --load-dot-env-file=true \
       --no-cache=true \
       --git-ssh $SSH_AUTH_SOCK
    @echo "✅ Version compatibility testing completed"

# 🔨 Verify the integrity of Terraform module files
[working-directory:'pipeline/infra']
pipeline-action-terraform-file-verification MODULE="default": (pipeline-infra-build)
    @echo " Testing module files"
    @echo "⚡ Running file verification"
    @dagger --use-hashicorp-image=true call action-terraform-file-verification \
       --tf-module-path="{{MODULE}}" \
       --load-dot-env-file=true \
       --no-cache=true
    @echo "✅ File verification completed"

# 🔨 Build Terraform modules
[working-directory:'pipeline/infra']
pipeline-action-terraform-build MODULE="default": (pipeline-infra-build)
    @echo " Building module files"
    @echo "⚡ Running plan"
    @dagger --use-hashicorp-image=true call action-terraform-build \
       --tf-module-path="{{MODULE}}" \
       --load-dot-env-file=true \
       --no-cache=true
    @echo "✅ Build completed"

# 🔨 Generate module documentation
[working-directory:'pipeline/infra']
pipeline-action-terraform-docs MODULE="default": (pipeline-infra-build)
    @echo " Generating module documentation"
    @echo "⚡ Running docs"
    @dagger --use-hashicorp-image=true call action-terraform-docs \
       --tf-module-path="{{MODULE}}" \
       --load-dot-env-file=true \
       --no-cache=true
    @echo "✅ Docs completed"

[working-directory:'pipeline/infra']
pipeline-action-terraform-lint MODULE="default": (pipeline-infra-build)
    @echo " Linting module files"
    @echo "⚡ Running lint"
    @dagger --use-hashicorp-image=true call action-terraform-lint \
       --tf-module-path="{{MODULE}}" \
       --load-dot-env-file=true \
       --no-cache=true
    @echo "✅ Lint completed"

# 🔨 Run comprehensive CI checks for Terraform modules
pipeline-infra-tf-ci MODULE="default" args="": (pipeline-action-terraform-static-analysis MODULE args) (pipeline-action-terraform-version-compatibility-verification MODULE) (pipeline-action-terraform-file-verification MODULE)
