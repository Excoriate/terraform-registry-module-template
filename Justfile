# Justfile for Terraform Module Development
# Load environment variables from .env file
set dotenv-load

# Default task to show available recipes
default:
    @just --list

# 🪝 Initialize pre-commit hooks
hooks-init:
    bash scripts/hooks/pre-commit-init.sh init

# 🏃 Run pre-commit hooks on all files
hooks-run:
    bash scripts/hooks/pre-commit-init.sh run

# 🧹 Clean Terraform and Terragrunt cache directories
tf-clean:
    find . -type d -name ".terraform" -exec rm -rf {} +
    find . -type d -name ".terragrunt-cache" -exec rm -rf {} +

# 🚀 Initialize Terraform module
tfmod-init module="default":
    cd modules/{{module}} && terraform init

# 🚀 Initialize Terraform in a module located in the examples/ directory
tfexm-init module="default" *args:
    cd examples/{{module}} && terraform init {{args}}

# 📋 Plan Terraform module changes
tf-plan module="default" vars="fixtures.tfvars":
    cd modules/{{module}} && terraform init && terraform plan -var-file={{vars}}

# 🏗️ Apply Terraform module changes
tf-apply module="default" vars="fixtures.tfvars":
    cd modules/{{module}} && terraform init && terraform apply -var-file={{vars}}

# 💥 Destroy Terraform module resources
tf-destroy module="default" vars="fixtures.tfvars":
    cd modules/{{module}} && terraform init && terraform destroy -var-file={{vars}}

# 🕵️ Lint Terraform module (formatting and tflint)
tf-lint module="default":
    cd modules/{{module}} && terraform fmt -check && tflint

# 📄 Generate Terraform module documentation
tf-docs module="default":
    cd modules/{{module}} && terraform-docs markdown table --output-file README.md .

# 🧹 Tidy Go module dependencies
go-tidy module="default":
    cd tests/{{module}}/unit && go mod tidy

# 🎨 Format Go code
go-fmt module="default":
    cd tests/{{module}}/unit && go fmt ./...

# 🔍 Vet Go code for potential issues
go-vet module="default":
    cd tests/{{module}}/unit && go vet ./...

# 🧪 Lint Go code
go-lint module="default":
    cd tests/{{module}}/unit && golangci-lint run

# 🚦 Run Go tests
go-test module="default":
    cd tests/{{module}}/unit && go test ./...

# 🔬 Comprehensive Go code quality checks
go-ci module="default": (go-fmt) (go-vet) (go-lint) (go-test)

# 🤖 Comprehensive CI task for module
ci module="default":
    just tf-lint {{module}}
    just tf-docs {{module}}
    just go-ci {{module}}

# ⬆️ Upgrade Terraform module dependencies to latest version
tf-upgrade:
    find modules -type f -name "versions.tf" -exec sed -i '' 's/required_version = "[^"]*"/required_version = ">= 1.7.0"/' {} +
    find examples -type f -name "versions.tf" -exec sed -i '' 's/required_version = "[^"]*"/required_version = ">= 1.7.0"/' {} +

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
