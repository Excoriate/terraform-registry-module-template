# 🛠️ Development Tools and Workflow Guide

## 📋 Overview

This guide provides a comprehensive overview of the development tools and workflow recipes available in our Terraform Module Template project. At its core, our development approach is built on several key principles:

1. **Reproducibility**: Ensuring consistent development environments across different machines and team members
2. **Automation**: Minimizing manual steps and reducing potential for human error
3. **Best Practices**: Enforcing code quality, security, and standardization through automated tools
4. **Flexibility**: Supporting both local and containerized/Nix-based development workflows

The project uses `just` as a task runner to simplify and standardize development processes, providing both local and Nix environment variants for most tasks. This approach allows developers to:

- Quickly set up development environments
- Run consistent commands across different development setups
- Automatically apply linting, formatting, and validation checks
- Easily manage project-specific tooling and dependencies

### Key Development Tools

- **Task Runner**: `just` for standardized command execution
- **Environment Management**: Nix and direnv for reproducible development environments
- **Code Quality**:
  - Pre-commit hooks for automated checks
  - Linters for Terraform, Go, Shell, and YAML
  - Formatters to maintain consistent code style
- **Testing**: Comprehensive test suites for Terraform modules
- **Documentation**: Automated documentation generation

## 🚀 Prerequisites

Before getting started, ensure you have the following tools installed:
- `just` (task runner)
- `terraform`
- `go`
- `pre-commit`
- `golangci-lint`
- `terraform-docs`
- `tflint`
- `shellcheck`
- `yamllint`
- `nix` (for Nix environment tasks)
- `direnv` (optional, for environment management)

## 🧰 Available Recipes

### 🔧 Environment and Hooks

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `hooks-install` | Install pre-commit hooks locally | `just hooks-install` | Ensures code quality before commits |
| `hooks-install-nix` | Install pre-commit hooks in Nix environment | `just hooks-install-nix` | Ensures code quality in Nix environment |
| `hooks-run` | Run pre-commit hooks on all files locally | `just hooks-run` | Validates code before pushing |
| `hooks-run-nix` | Run pre-commit hooks on all files in Nix environment | `just hooks-run-nix` | Validates code in Nix environment |
| `dev` | Launch Nix development shell | `just dev` | Provides a consistent development environment |

### 🧹 Cleanup Utilities

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `clean-tf` | Remove Terraform and Terragrunt cache directories | `just clean-tf` | Resets Terraform state across repository |
| `clean-tf-mod` | Remove Terraform and Terragrunt cache for a specific module | `just clean-tf-mod default` | Resets Terraform state for a module |
| `clean` | Remove general project artifacts | `just clean` | Removes logs, DS_Store files |
| `clean-all` | Comprehensive cleanup of project artifacts | `just clean-all` | Combines `clean` and `clean-tf` |

### 🌿 Terraform Workflow

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `tf-format` | Format Terraform files locally | `just tf-format` or `just tf-format default` | Ensures consistent code style |
| `tf-format-nix` | Format Terraform files in Nix environment | `just tf-format-nix` or `just tf-format-nix default` | Ensures consistent code style in Nix |
| `tf-format-check` | Check Terraform file formatting locally | `just tf-format-check` or `just tf-format-check default` | Validates code formatting |
| `tf-format-check-nix` | Check Terraform file formatting in Nix | `just tf-format-check-nix` or `just tf-format-check-nix default` | Validates code formatting in Nix |
| `tf-lint` | Lint Terraform modules locally | `just tf-lint` or `just tf-lint default` | Checks for best practices |
| `tf-lint-nix` | Lint Terraform modules in Nix environment | `just tf-lint-nix` or `just tf-lint-nix default` | Checks for best practices in Nix |
| `tf-docs-generate` | Generate module documentation locally | `just tf-docs-generate` or `just tf-docs-generate default` | Creates README.md for modules |
| `tf-docs-generate-nix` | Generate module documentation in Nix | `just tf-docs-generate-nix` or `just tf-docs-generate-nix default` | Creates README.md in Nix environment |
| `tf-validate` | Validate Terraform modules locally | `just tf-validate default` | Checks module configuration |
| `tf-validate-nix` | Validate Terraform modules in Nix | `just tf-validate-nix default` | Checks module configuration in Nix |
| `tf-exec` | Run Terraform commands with flexible working directory | `just tf-exec . 'init'` | Flexible Terraform command execution |
| `tf-exec-nix` | Run Terraform commands in Nix environment | `just tf-exec-nix . 'init'` | Flexible Terraform command in Nix |
| `tf-cmd` | Run Terraform commands for a specific module | `just tf-cmd default init` | Module-specific Terraform commands |
| `tf-cmd-nix` | Run Terraform commands for a module in Nix | `just tf-cmd-nix default init` | Module-specific Terraform in Nix |
| `tofu-cmd` | Run OpenTofu commands locally | `just tofu-cmd default init` | OpenTofu module-specific commands |
| `tofu-cmd-nix` | Run OpenTofu commands in Nix | `just tofu-cmd-nix default init` | OpenTofu module-specific in Nix |
| `tf-dev` | Quick development feedback loop | `just tf-dev default basic` | Runs formatting, linting, and initialization |
| `tf-dev-nix` | Quick development feedback loop in Nix | `just tf-dev-nix default basic` | Runs formatting, linting, and initialization in Nix |
| `tf-ci-static` | Run Terraform CI checks locally | `just tf-ci-static default` | Runs static code checks |
| `tf-ci-static-nix` | Run Terraform CI checks in Nix | `just tf-ci-static-nix default` | Runs static code checks in Nix |

### 🐹 Go Workflow

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `go-format` | Format Go files locally | `just go-format` | Ensures Go code style |
| `go-format-nix` | Format Go files in Nix environment | `just go-format-nix` | Ensures Go code style in Nix |
| `go-lint` | Lint Go files locally | `just go-lint` | Checks Go code quality |
| `go-lint-nix` | Lint Go files in Nix environment | `just go-lint-nix` | Checks Go code quality in Nix |
| `go-tidy` | Tidy Go module dependencies locally | `just go-tidy` | Manages Go dependencies |
| `go-tidy-nix` | Tidy Go module dependencies in Nix | `just go-tidy-nix` | Manages Go dependencies in Nix |
| `go-ci` | Comprehensive Go checks locally | `just go-ci` | Runs formatting, linting, and tidying |
| `go-ci-nix` | Comprehensive Go checks in Nix | `just go-ci-nix` | Runs formatting, linting, and tidying in Nix |
| `tf-test-unit` | Run unit tests with isolated provider cache | `just tf-test-unit [MOD=default] [TAGS=readonly] [NOCACHE=true] [TIMEOUT=60s]` | Runs Terraform module unit tests with various options |
| `tf-test-unit-nix` | Run unit tests in Nix environment | `just tf-test-unit-nix [MOD=default] [TAGS=readonly] [NOCACHE=true] [TIMEOUT=60s]` | Runs Terraform module unit tests in Nix |
| `tf-test-examples` | Run example tests with isolated provider cache | `just tf-test-examples [MOD=default] [TAGS=readonly] [NOCACHE=true] [TIMEOUT=60s]` | Runs Terraform module example tests |
| `tf-test-examples-nix` | Run example tests in Nix environment | `just tf-test-examples-nix [MOD=default] [TAGS=readonly] [NOCACHE=true] [TIMEOUT=60s]` | Runs Terraform module example tests in Nix |

### 🧪 Testing Parameters

The test recipes accept several parameters to customize test execution:

- `MOD`: Specifies the module to test (e.g., `default`, `mymodule`)
- `TAGS`: Specifies additional test tags (e.g., `readonly`, `integration`)
- `NOCACHE`: Controls Go test caching - set to `true` to force tests to run (default: `true`)
- `TIMEOUT`: Specifies test timeout duration (e.g., `60s`, `5m`, `1h`)

### 🔄 Testing Workflow

The test recipes work in tandem with helper functions in the `tests/pkg/helper/terraform.go` file to provide:

1. **Isolated Terraform Provider Cache**:
   - Each test gets its own provider cache directory
   - Automatic cleanup of cache directories after tests
   - Prevents conflicts between parallel test executions

2. **Simplified Test Setup**:
   - Helper functions handle path resolution and environment setup
   - Common patterns for all test types (example tests, unit tests)
   - Cleaner test code focusing on test logic

3. **Test Types**:
   - **Unit Tests** (`tf-test-unit`): Test modules against test-specific configurations in `tests/modules/<module>/target/` directory
   - **Example Tests** (`tf-test-examples`): Test example implementations in `examples/<module>/` directory

### 📚 Helper Functions

The test recipes rely on three main helper functions:

1. **SetupTerraformOptions**: For testing example implementations
   ```go
   // Used in example tests
   terraformOptions := helper.SetupTerraformOptions(t, "default/basic", vars)
   ```

2. **SetupTargetTerraformOptions**: For unit tests using target directories
   ```go
   // Used in unit tests
   terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "basic", vars)
   ```

3. **SetupModuleTerraformOptions**: For testing modules directly
   ```go
   // Used in module tests
   terraformOptions := helper.SetupModuleTerraformOptions(t, dirs.GetModulesDir("default"), vars)
   ```

### 📋 Example Testing Commands

```bash
# Run all unit tests for default module with readonly tag
just tf-test-unit

# Run integration tests for a specific module
just tf-test-unit MOD=mymodule TAGS=integration

# Run example tests with a 5-minute timeout
just tf-test-examples TIMEOUT=5m

# Run example tests for a specific module without caching
just tf-test-examples MOD=custommod NOCACHE=true

# Run all tests in Nix environment
just tf-test-unit-nix
just tf-test-examples-nix
```

### 🌐 YAML Workflow

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `yaml-fix` | Format and lint YAML files locally | `just yaml-fix` | Ensures YAML consistency |
| `yaml-fix-nix` | Format and lint YAML files in Nix | `just yaml-fix-nix` | Ensures YAML consistency in Nix |
| `yaml-lint` | Validate YAML files locally | `just yaml-lint` | Checks YAML configuration |
| `yaml-lint-nix` | Validate YAML files in Nix | `just yaml-lint-nix` | Checks YAML configuration in Nix |

### 🐚 Shell Script Workflow

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `scripts-lint` | Lint shell scripts locally | `just scripts-lint` | Checks shell script quality |
| `scripts-lint-nix` | Lint shell scripts in Nix | `just scripts-lint-nix` | Checks shell script quality in Nix |

### 🔓 Direnv Management

| Recipe | Description | Usage | Example |
|--------|-------------|-------|---------|
| `allow-direnv` | Enable direnv for environment management | `just allow-direnv` | Allows direnv configuration |
| `reload-direnv` | Reload direnv environment | `just reload-direnv` | Reloads direnv configuration |

## 🔍 Nix Environment Variants

Most recipes have a `-nix` variant (e.g., `go-lint-nix`, `tf-format-nix`) that runs the command in a Nix development environment. This ensures:

1. **Consistent Tooling**: Reproducible development setup across different machines
2. **Isolated Environments**: Prevents conflicts with system-wide tool versions
3. **Declarative Configuration**: Uses `flake.nix` for precise dependency management

### Using Nix Environment Variants

- To run a task in the Nix environment, append `-nix` to the recipe name
- Example: `just go-lint` (local) vs `just go-lint-nix` (Nix environment)
- Use `just dev` to launch a full Nix development shell with all project dependencies

## 💡 Pro Tips

1. Use `just help` to see all available recipes
2. Prefix commands with `just` instead of running tools directly
3. Use module-specific commands by specifying the module name (e.g., `just tf-format default`)
4. Leverage Nix environment variants for reproducible development
5. Use `just dev` to start a comprehensive development environment
6. Explore both local and Nix environment variants of recipes

## 🚧 Troubleshooting

- If a recipe fails, check the specific error message
- Ensure all prerequisites are installed
- Use the Nix environment (`just dev`) for the most consistent setup

## 📚 Learning Resources

- [Just Documentation](https://just.systems/man/en/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Go Documentation](https://golang.org/doc/)
