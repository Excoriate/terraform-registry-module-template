# Justfile Recipes Guide

This guide provides a comprehensive overview of the Justfile recipes available in this repository. The Justfile is used to automate common development and CI/CD tasks, providing a consistent interface for various workflows.

## Table of Contents

- [Justfile Recipes Guide](#justfile-recipes-guide)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting Started](#getting-started)
  - [General Recipes](#general-recipes)
  - [Environment and Hooks](#environment-and-hooks)
  - [Cleanup Utilities](#cleanup-utilities)
  - [Terraform Workflow](#terraform-workflow)
  - [Go Workflow](#go-workflow)
  - [Testing](#testing)
  - [Dagger Pipeline](#dagger-pipeline)
  - [Nix Environment Variants](#nix-environment-variants)
  - [Tips and Tricks](#tips-and-tricks)

## Introduction

The `Justfile` in this repository serves as a central command runner, abstracting complex shell commands and scripts into simple, memorable recipes. This ensures that common tasks like formatting, linting, testing, and deployment are executed consistently across all development environments.

Key benefits of using Justfile:
- **Consistency:** Ensures everyone on the team runs the same commands with the same options.
- **Automation:** Automates repetitive tasks, reducing manual effort and errors.
- **Discoverability:** Provides a clear list of available commands with descriptions (`just --list`).
- **Reproducibility:** Can be combined with tools like Nix to create reproducible development environments.

## Getting Started

1. **Install Just:** Follow the installation instructions in the main [README.md](../README.md).
2. **View Available Recipes:** Run `just` in the project root to see a list of all available recipes and their descriptions.

```bash
just
```

## General Recipes

| Recipe | Description | Usage | Notes |
|--------|-------------|-------|-------|
| `help` | Displays all available recipes with descriptions. | `just help` | Default recipe if no task is specified. |

## Environment and Hooks

These recipes help set up the development environment and manage pre-commit hooks for code quality.

| Recipe | Description | Usage | Notes |
|--------|-------------|-------|-------|
| `hooks-install` | Installs pre-commit hooks locally. | `just hooks-install` | Runs `./scripts/hooks/pre-commit-init.sh init` |
| `hooks-install-nix` | Installs pre-commit hooks in the Nix environment. | `just hooks-install-nix` | Requires Nix and `nix develop . --command pre-commit install` |
| `hooks-run` | Runs pre-commit hooks on all files locally. | `just hooks-run` | Runs `./scripts/hooks/pre-commit-init.sh run` |
| `hooks-run-nix` | Runs pre-commit hooks on all files in the Nix environment. | `just hooks-run-nix` | Requires Nix and `nix develop . --command pre-commit run --all-files` |
| `dev` | Launches a Nix development shell with project dependencies. | `just dev` | Provides a reproducible environment for development. |
| `allow-direnv` | Enables direnv for environment variable management. | `just allow-direnv` | Useful if using direnv to load `.env` files. |
| `reload-direnv` | Reloads the direnv environment. | `just reload-direnv` | Apply changes after modifying `.env` files. |

## Cleanup Utilities

Recipes for cleaning up generated files, cache directories, and state files.

| Recipe | Description | Usage | Notes |
|--------|-------------|-------|-------|
| `clean-tf` | Removes Terraform and Terragrunt cache directories across the entire repository. | `just clean-tf` | Deletes `.terraform` and `.terragrunt-cache` folders and state files. |
| `clean-tf-mod <MODULE>` | Removes Terraform and Terragrunt cache for a specific module. | `just clean-tf-mod mymodule` | Requires module name. |
| `clean` | Removes general project artifacts (`.DS_Store`, `.log` files). | `just clean` | Basic cleanup. |
| `clean-all` | Performs comprehensive cleanup (combines `clean` and `clean-tf`). | `just clean-all` | Resets project to a clean state. |

## Terraform Workflow

Recipes for formatting, linting, validating, and executing Terraform commands.

| Recipe | Description | Usage | Parameters | Notes |
|--------|-------------|-------|------------|-------|
| `tf-format` | Formats Terraform files in the current directory locally. | `just tf-format` | None | Uses `./scripts/utilities/format.sh --terraform` |
| `tf-format-all` | Formats all Terraform files across modules, examples, and tests directories. | `just tf-format-all` | None | Uses `./scripts/utilities/format.sh --terraform --tf-all-dirs` |
| `tf-format-module <MODULE>` | Formats Terraform files for a specific module (both module and example directories). | `just tf-format-module mymodule` | `MODULE` (module name) | Uses `./scripts/utilities/format.sh --terraform --tf-module <MODULE>` |
| `tf-format-check` | Checks Terraform file formatting locally without modifying files. | `just tf-format-check` or `just tf-format-check mymodule` | Optional `MOD` (module name) | Uses `./scripts/utilities/format.sh --terraform --tf-check` |
| `tf-format-check-all` | Checks Terraform file formatting across all directories. | `just tf-format-check-all` | None | Uses `./scripts/utilities/format.sh --terraform --tf-check --tf-all-dirs` |
| `tf-format-check-module <MODULE>` | Checks Terraform file formatting for a specific module. | `just tf-format-check-module mymodule` | `MODULE` (module name) | Uses `./scripts/utilities/format.sh --terraform --tf-check --tf-module <MODULE>` |
| `tf-format-check-nix [MOD]` | Checks Terraform file formatting in Nix environment. | `just tf-format-check-nix` or `just tf-format-check-nix mymodule` | Optional `MOD` (module name) | Runs in Nix environment. |
| `tf-discover` | Discovers and lists all Terraform files in the repository. | `just tf-discover` | None | Uses `./scripts/utilities/format.sh --terraform --tf-discover` |
| `tf-exec <WORKDIR> <CMDS>` | Runs Terraform commands with a flexible working directory. | `just tf-exec examples/default/basic 'init -upgrade'` | `WORKDIR` (directory path), `CMDS` (Terraform commands) | Executes `terraform <CMDS>` in `<WORKDIR>`. |
| `tf-exec-nix <WORKDIR> <CMDS>` | Runs Terraform commands in Nix environment with a flexible working directory. | `just tf-exec-nix examples/default/basic 'init'` | `WORKDIR` (directory path), `CMDS` (Terraform commands) | Executes in Nix environment. |
| `tf-exec-mod <MODULE> <CMDS>` | Runs Terraform commands locally for a specific module. | `just tf-exec-mod default 'validate'` | `MODULE` (module name), `CMDS` (Terraform commands) | Executes in the module directory. |
| `tf-exec-mod-cmd-nix <MODULE> <CMDS>` | Runs Terraform commands in Nix environment for a specific module. | `just tf-exec-mod-cmd-nix default 'plan'` | `MODULE` (module name), `CMDS` (Terraform commands) | Executes in the module directory in Nix. |
| `tofu-exec-mod <MODULE> <CMDS>` | Runs OpenTofu commands locally for a specific module. | `just tofu-exec-mod default 'init'` | `MODULE` (module name), `CMDS` (OpenTofu commands) | Executes in the module directory. |
| `tofu-exec-mod-cmd-nix <MODULE> <CMDS>` | Runs OpenTofu commands in Nix environment for a specific module. | `just tofu-exec-mod-cmd-nix default 'plan'` | `MODULE` (module name), `CMDS` (OpenTofu commands) | Executes in the module directory in Nix. |
| `tf-lint [MODULE]` | Runs TFLint on Terraform files to check for issues and best practices locally. | `just tf-lint` or `just tf-lint mymodule` | Optional `MODULE` (module name) | Uses `./scripts/utilities/tflint.sh` |
| `tf-lint-nix [MODULE]` | Runs TFLint on Terraform files in Nix environment. | `just tf-lint-nix` or `just tf-lint-nix mymodule` | Optional `MODULE` (module name) | Runs `./scripts/utilities/tflint.sh --nix` |
| `tf-docs-generate [MODULE]` | Generates Terraform documentation using `terraform-docs` locally. | `just tf-docs-generate` or `just tf-docs-generate mymodule` | Optional `MODULE` (module name) | Uses `./scripts/utilities/tfdocs.sh` |
| `tf-docs-generate-nix [MODULE]` | Generates Terraform documentation using `terraform-docs` in Nix environment. | `just tf-docs-generate-nix` or `just tf-docs-generate-nix mymodule` | Optional `MODULE` (module name) | Runs `./scripts/utilities/tfdocs.sh --nix` |
| `tf-validate <MODULE>` | Validates Terraform modules locally. | `just tf-validate default` | `MODULE` (module name) | Runs `init -backend=false` and `validate` in the module directory. |
| `tf-validate-nix <MODULE>` | Validates Terraform modules in Nix environment. | `just tf-validate-nix default` | `MODULE` (module name) | Runs in Nix environment. |
| `tf-ci-static [MODULE]` | Runs Terraform static CI checks locally (fmt, lint, docs, validate). | `just tf-ci-static default` | Optional `MODULE` (module name) | Good for quick local validation. |
| `tf-ci-static-nix [MODULE]` | Runs Terraform static CI checks in Nix environment. | `just tf-ci-static-nix default` | Optional `MODULE` (module name) | Consistent checks in Nix. |
| `tf-dev <MODULE> <EXAMPLE> [FIXTURE] [CLEAN]` | Quick feedback loop for development (clean, static checks, init, validate, plan). | `just tf-dev default basic default.tfvars true` | `MODULE`, `EXAMPLE`, Optional `FIXTURE`, Optional `CLEAN` | Helps iterate quickly on module and example changes. |
| `tf-dev-nix <MODULE> <EXAMPLE> [FIXTURE] [CLEAN]` | Quick feedback loop for development in Nix environment. | `just tf-dev-nix default basic default.tfvars true` | `MODULE`, `EXAMPLE`, Optional `FIXTURE`, Optional `CLEAN` | Nix environment variant of `tf-dev`. |
| `tf-dev-full <MODULE> <EXAMPLE> [FIXTURE] [CLEAN]` | Quick feedback loop including apply and destroy (local). | `just tf-dev-full default basic default.tfvars true` | `MODULE`, `EXAMPLE`, Optional `FIXTURE`, Optional `CLEAN` | Extends `tf-dev` with apply/destroy. |
| `tf-dev-full-nix <MODULE> <EXAMPLE> [FIXTURE] [CLEAN]` | Quick feedback loop including apply and destroy (Nix). | `just tf-dev-full-nix default basic default.tfvars true` | `MODULE`, `EXAMPLE`, Optional `FIXTURE`, Optional `CLEAN` | Nix environment variant of `tf-dev-full`. |

## Go Workflow

Recipes for formatting, linting, and building Go code, primarily used for Terratest.

| Recipe | Description | Usage | Notes |
|--------|-------------|-------|-------|
| `go-format` | Formats Go files locally in the tests directory. | `just go-format` | Uses `gofmt`. |
| `go-format-nix` | Formats Go files in Nix environment. | `just go-format-nix` | Runs `gofmt` in Nix. |
| `go-lint-tests` | Lints Go test files locally using `golangci-lint`. | `just go-lint-tests` | Uses `.golangci-tests.yml` config. |
| `go-lint-tests-nix` | Lints Go test files in Nix environment. | `just go-lint-tests-nix` | Runs in Nix environment. |
| `go-lint-pipeline` | Lints Dagger pipeline Go files locally. | `just go-lint-pipeline` | Uses `.golangci-pipeline.yml` config. |
| `go-lint-pipeline-nix` | Lints Dagger pipeline Go files in Nix environment. | `just go-lint-pipeline-nix` | Runs in Nix environment. |
| `go-lint-all` | Lints all Go files (tests + pipeline) locally. | `just go-lint-all` | Combines `go-lint-tests` and `go-lint-pipeline`. |
| `go-lint-all-nix` | Lints all Go files in Nix environment. | `just go-lint-all-nix` | Combines `go-lint-tests-nix` and `go-lint-pipeline-nix`. |
| `go-tidy` | Tidies Go module dependencies locally in the tests directory. | `just go-tidy` | Runs `go mod tidy`. |
| `go-tidy-nix` | Tidies Go module dependencies in Nix environment. | `just go-tidy-nix` | Runs `go mod tidy` in Nix. |
| `go-build-tests` | Builds the Go test module locally. | `just go-build-tests` | Validates compilation. |
| `go-build-tests-nix` | Builds the Go test module in Nix environment. | `just go-build-tests-nix` | Validates compilation in Nix. |
| `go-ci` | Runs comprehensive Go CI checks locally (tidy, format, build, lint). | `just go-ci` | Full local Go check. |
| `go-ci-nix` | Runs comprehensive Go CI checks in Nix environment. | `just go-ci-nix` | Full Go check in Nix. |

## Testing

Recipes for running unit and example tests using Terratest.

| Recipe | Description | Usage | Parameters | Notes |
|--------|-------------|-------|------------|-------|
| `tf-test-unit [TAGS] [MODULE] [NOCACHE] [TIMEOUT]` | Runs unit tests with isolated provider cache locally. | `just tf-test-unit TAGS=readonly MODULE=default NOCACHE=true TIMEOUT=60s` | `TAGS`, `MODULE`, `NOCACHE`, `TIMEOUT` | Tests against test-specific configs. |
| `tf-test-unit-nix [TAGS] [MODULE] [NOCACHE] [TIMEOUT]` | Runs unit tests in Nix environment. | `just tf-test-unit-nix` | `TAGS`, `MODULE`, `NOCACHE`, `TIMEOUT` | Nix environment variant. |
| `tf-test-examples [TAGS] [MODULE] [NOCACHE] [TIMEOUT]` | Runs example tests with isolated provider cache locally. | `just tf-test-examples` | `TAGS`, `MODULE`, `NOCACHE`, `TIMEOUT` | Tests example implementations. |
| `tf-test-examples-nix [TAGS] [MODULE] [NOCACHE] [TIMEOUT]` | Runs example tests in Nix environment. | `just tf-test-examples-nix` | `TAGS`, `MODULE`, `NOCACHE`, `TIMEOUT` | Nix environment variant. |

**Test Parameters:**
- `TAGS`: Additional Go test tags (e.g., `readonly`, `integration`). Separate multiple tags with commas.
- `MODULE`: The name of the module to test. Defaults to `default`.
- `NOCACHE`: Set to `true` to disable Go test caching and force execution. Defaults to `true`.
- `TIMEOUT`: Test timeout duration (e.g., `60s`, `5m`, `1h`).

## Dagger Pipeline

Recipes for interacting with the Dagger-based CI pipeline.

| Recipe | Description | Usage | Parameters | Notes |
|--------|-------------|-------|------------|-------|
| `pipeline-infra-build` | Initializes and builds the Dagger pipeline. | `just pipeline-infra-build` | None | Needs to be run before executing Dagger jobs. |
| `pipeline-job-help <fn>` | Displays help for a specific Dagger job function. | `just pipeline-job-help job-terraform-exec` | `fn` (Dagger function name) | Useful for understanding job parameters. |
| `pipeline-infra-shell [args]` | Opens an interactive development shell for the Dagger pipeline. | `just pipeline-infra-shell` | Optional `args` | For debugging and exploring the Dagger environment. |
| `pipeline-job-exec <mod> <command> [args]` | Executes a Dagger job to run a Terraform command for a module. | `just pipeline-job-exec default init '-upgrade'` | `mod` (module name), `command` (Terraform command), Optional `args` | Runs Terraform commands within the Dagger container. |
| `pipeline-action-terraform-static-analysis <MODULE> [args]` | Performs static analysis on Terraform modules using Dagger. | `just pipeline-action-terraform-static-analysis default` | `MODULE` (module name), Optional `args` | Checks for security and best practices. |
| `pipeline-action-terraform-version-compatibility-verification <MODULE>` | Verifies module compatibility across different provider versions using Dagger. | `just pipeline-action-terraform-version-compatibility-verification default` | `MODULE` (module name) | Ensures modules work with specified provider versions. |
| `pipeline-action-terraform-file-verification <MODULE>` | Verifies the integrity of Terraform module files using Dagger. | `just pipeline-action-terraform-file-verification default` | `MODULE` (module name) | Checks for file existence and basic structure. |
| `pipeline-action-terraform-build <MODULE>` | Builds Terraform modules using Dagger (runs plan). | `just pipeline-action-terraform-build default` | `MODULE` (module name) | Executes `terraform plan` within Dagger. |
| `pipeline-action-terraform-docs <MODULE>` | Generates module documentation using Dagger. | `just pipeline-action-terraform-docs default` | `MODULE` (module name) | Runs `terraform-docs` within Dagger. |
| `pipeline-action-terraform-lint <MODULE>` | Lints module files using Dagger. | `just pipeline-action-terraform-lint default` | `MODULE` (module name) | Runs TFLint within Dagger. |
| `pipeline-infra-tf-ci <MODULE> [args]` | Runs comprehensive Terraform CI checks using Dagger (static analysis, version compatibility, file verification). | `just pipeline-infra-tf-ci default` | `MODULE` (module name), Optional `args` | Combines multiple Dagger actions. |

## Nix Environment Variants

Many recipes have a `-nix` suffix (e.g., `go-lint-nix`, `tf-format-nix`). These variants execute the recipe's commands within a reproducible Nix development environment defined in `flake.nix`. This is the recommended way to run tasks to ensure consistent tooling and dependencies.

To use a Nix variant, simply append `-nix` to the recipe name:

```bash
just go-lint      # Runs Go lint locally
just go-lint-nix  # Runs Go lint in the Nix environment
```

Using `just dev` provides an interactive shell with all necessary tools loaded, allowing you to run commands directly within the Nix environment.

## Tips and Tricks

- Run `just --list` to see all recipes and their descriptions.
- Use the `-n` flag to preview the commands a recipe will run without executing them (e.g., `just -n tf-format`).
- Leverage the `-f <Justfile>` option if you have multiple Justfiles (though typically you'll only have one in the project root).
- Combine recipes using dependencies for complex workflows (see the Justfile for examples like `tf-validate` or `go-ci`).

This guide should provide new contributors with a solid understanding of how to use the Justfile recipes to streamline their development workflow. 
