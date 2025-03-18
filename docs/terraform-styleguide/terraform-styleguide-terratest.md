# Terraform Terratest StyleGuide: Mandatory Testing Standards and Practices

## Table of Contents

- [Terraform Terratest StyleGuide: Mandatory Testing Standards and Practices](#terraform-terratest-styleguide-mandatory-testing-standards-and-practices)
  - [Table of Contents](#table-of-contents)
  - [Purpose and Scope](#purpose-and-scope)
  - [Styleguide: Fundamental Principles of Terraform Testing](#styleguide-fundamental-principles-of-terraform-testing)
    - [Rule: Testing Philosophy](#rule-testing-philosophy)
    - [Rule: Type of Tests](#rule-type-of-tests)
    - [Rule: Build Tags](#rule-build-tags)
    - [Rule: Test Targets](#rule-test-targets)
  - [Styleguide: Test Naming Conventions](#styleguide-test-naming-conventions)
    - [Rule: Test Directory Layout](#rule-test-directory-layout)
    - [Rule: Go code, and utilities in the `pkg/` directory](#rule-go-code-and-utilities-in-the-pkg-directory)
      - [pkg/repo/finder.go](#pkgrepofindergo)
      - [pkg/helper/terraform.go](#pkghelperterraformgo)
    - [Recommended Usage](#recommended-usage)
    - [Rule: Unit Test Conventions](#rule-unit-test-conventions)
      - [Rule: Examples Tests Conventions](#rule-examples-tests-conventions)
    - [Rule: Quality of the Tests written (Terratest)](#rule-quality-of-the-tests-written-terratest)
    - [Rule: Example of a Well-Structured Test File](#rule-example-of-a-well-structured-test-file)
  - [Styleguide: Test Implementation Rules](#styleguide-test-implementation-rules)
    - [Rule: Terratest Rules](#rule-terratest-rules)
  - [Styleguide: Test Execution Rules](#styleguide-test-execution-rules)
    - [Rule: Using Justfile Commands](#rule-using-justfile-commands)

## Purpose and Scope

This document provides comprehensive guidelines for implementing tests for Terraform modules using Terratest, ensuring consistent, reliable, and maintainable test suites that validate module functionality and serve as executable documentation.

## Styleguide: Fundamental Principles of Terraform Testing

### Rule: Testing Philosophy

- ENSURE tests validate both resource creation and configuration of the target module.
- ALWAYS the tests validate the two dimension when creating IaaC with Terraform: 1) the module's configuration, and 2) the module's features.
  - The module's configuration: Is the module returning the expected plan output under certain conditions? is the module's output the one expected? are the resources created?
  - The module's features: Is the module's feature working as expected? Are the resources created with the declared configuration and reflect as such in the provider's API?
- ALWAYS use the latest version of Terratest, and the latest version of Terraform.
- ALWAYS check, and refresh your memory reading these guidelines, and the [Terratest](https://terratest.gruntwork.io/) documentation.
- TOTALLY PROHIBITED flaky tests, or tests that are not deterministic.
- ALWAYS integration tests require apply the resources, and test with the provider's API (AWS, GCP, etc.) the actual resources created before they're destroyed.

### Rule: Type of Tests

There are two types of tests based on **their scope**:

1. **Unit Tests**: These tests are used to test the module's configuration and individual features. They are always located in the `tests/[module-name]/unit` directory, and always use the terraform configuration in the `tests/modules/[module-name]/target/[use-case-name]/main.tf` file.
2. **Examples(s) Tests**: These tests are meant to test the example(s) implementation of the module. They are always located in the `tests/[module-name]/examples` directory, and always use the terraform configuration in the `tests/modules/[module-name]/examples/[example-name]` to execute the terratest tests.

### Rule: Build Tags

- Build tags are directives that control which Go source files are included in a package during compilation.
- ALWAYS use the modern `//go:build` syntax (introduced in Go 1.17) at the very top of the file:

```go
//go:build integration && examples

package examples
```

- The following build tags are used to categorize tests:
  - `readonly`: Tests that validate module configuration without applying resources (no terraform apply/destroy).
  - `integration`: Tests that run the full Terraform lifecycle (init, apply, validate with provider API, destroy). These tests require provider credentials.
  - `unit`: Tests for module configuration and individual features in the `tests/[module-name]/unit` directory.
  - `examples`: Tests for example implementations in the `examples/[module-name]/[example-name]` directory.

- ALWAYS place build tags at the very top of the file with a blank line after them.
- ALWAYS use logical operators to combine build tags appropriately:
  - `&&` (AND): Both conditions must be true (e.g., `//go:build integration && examples`)
  - `||` (OR): Either condition can be true (e.g., `//go:build linux || darwin`)
  - `!` (NOT): Negates a condition (e.g., `//go:build !windows`)

- For example tests, ALWAYS use the combination of the test type and `examples` tag:
  - Integration example tests: `//go:build integration && examples`
  - Read-only example tests: `//go:build readonly && examples`

- For unit tests, ALWAYS use the combination of the test type and `unit` tag:
  - Integration unit tests: `//go:build integration && unit`
  - Read-only unit tests: `//go:build readonly && unit`

- NEVER mix incompatible tags (e.g., don't combine `readonly` and `integration` with AND logic).

### Rule: Test Targets

The test targets are the sources of the terraform configuration files (or modules) that are being tested, and from where the tests [terratest](https://terratest.gruntwork.io/) will be executed against.

- ALWAYS, with no exception, acknowledge the following test targets:

| Test Target (target is where the *.tf files and the modules are located)                                   | Description                                                  |
|-----------------------------------------------|--------------------------------------------------------------|
| `modules/[module-name]`                       | The main module being tested. Only run tests against this target for static analysis, and read-only tests (terraform init, terraform validate, etc.).                               |
| `examples/[module-name]/[example-name]`                | Example implementation of the module that shows different use-cases, and scenarios of the module. |
| `tests/[module-name]/target/[use-case-name]/` | Use-case specific test suite for particular features of the module that's in the `tests/[module-name]/target/` directory. Suitable for unit tests, and integration tests, but mostly unit tests either read-only, or e2e. |

- ALWAYS, the target modules, or configurations in the `tests/[module-name]/target/[use-case-name]/` directory, are always a one-file terraform configuration, meaning they always have the `main.tf` file, and no other files for simplicity sake. See these examples:

```text
tests/
├── target/                     # Target test suite
│   ├── basic/                  # Basic use-case
│   │   └── main.tf             # Terraform configuration for basic use-case
│   └── with_multiple_options/  # Specific use-case for with_multiple_options
│       └── main.tf             # Terraform configuration for with_multiple_options use-case
```

## Styleguide: Test Naming Conventions

### Rule: Test Directory Layout

- FOLLOW ALWAYS this structure for all test implementations:

```text
tests/
├── README.md               # Testing documentation
├── go.mod                  # Go module dependencies
├── go.sum                  # Dependency lockfile
├── pkg/                    # Shared testing utilities
│   └── repo/               # Repository path utilities
│       └── finder.go       # Path resolution functions
│   └── helper/             # Helper utilities
│       └── resources.go    # Resources utilities
│       └── terraform.go    # Terraform utilities
└── modules/                # Module-specific test suites
    └── <module_name>/      # Tests for specific module
        ├── target/         # Use-case specific test suite
        │   ├── basic/      # Basic use-case configuration
        │   │   └── main.tf # Terraform configuration for basic use-case
        │   ├── specific_use_case/  # Specific use-case depending on the module's configuration, and capabilities
        │   │   └── main.tf # Terraform configuration for specific use-case
        │   └── disabled_module/  # Specific use-case for disabled configuration
        │       └── main.tf # Terraform configuration for disabled configuration use-case
        ├── unit/           # Unit test suite
        │   └── target_specific_use_case_ro_unit_test.go          # Read-only unit test for specific configuration
        │   └── target_specific_use_case_integration_test.go      # End-to-end integration test for specific use-case
        └── examples/    # Examples test suite, with e2e tests
            ├── example_complete_integration_test.go                # End-to-end integration test for complete example
            ├── example_basic_ro_test.go                            # Read-only unit test for basic example
            └── example_disabled_configuration_integration_test.go  # End-to-end integration test for disabled configuration example
```

- Boilerplate code that's always included in every test implementation:
  - `go.mod` and `go.sum` files, to manage the dependencies, since the Go modules are always created in advance. Always USE THE LATEST VERSION OF GO that's available. Currently, it's `1.24.0`.
  - `pkg/` directory, to manage the shared testing utilities. More utilities shared by all tests will be added incrementally.
- ALWAYS, use the unit directory to group the unit tests that are `readonly`, and `integration`. Which means, they test the module's configuration and individual features in the `tests/[module-name]/target/[use-case-name]/main.tf` files.
- ALWAYS, use the examples directory to group the examples tests. Which means, they test the examples implementation of the module in the `examples/[module-name]/[example-name]/main.tf` modules.
- ALWAYS create these TWO TARGET(S) USE CASES, BY DEFAULT:
  - `disabled_module`: A default target use-case to test the module disabled (with the input variable `is_enabled = false`), called `disabled_module` in the path `tests/[module-name]/target/disabled_module/main.tf`.
  - `basic`: A default target use-case to test the module enabled with very basic features (with the input variable `is_enabled = true`), called `basic` in the path `tests/[module-name]/target/basic/main.tf`.
- ALWAYS examine and utilize the pre-existing utilities in the `pkg/` directory:

### Rule: Go code, and utilities in the `pkg/` directory

- ALWAYS use the latest golang version available. Currently, it's `1.24.0`.
- STRICTLY adhere to the `.golangci.yml` file, to ensure the test files are well-written, and easy to understand.
- ALWAYS use Go Docs (verbose) for each Test Function, to explain what the test is verifying.
- ALWAYS write common utilities, and helpers in the `pkg/` directory, to be used across all tests.
- USE descriptive variable names
- FOLLOW Go naming conventions, and the Go effective practices.

#### pkg/repo/finder.go

- **GetGitRootDir()**: Finds the root directory of the Git repository.
- **NewTFSourcesDir()**: Creates a directory finder for Terraform sources, returning a struct with methods:
  - **GetModulesDir(moduleName)**: Retrieves the path to a specific module.
  - **GetExamplesDir(exampleName)**: Retrieves the path to a specific example.
  - **GetRootDir()**: Retrieves the repository root path.
  - **GetTargetDir(moduleName, targetName)**: Retrieves the path to a specific target test directory.

#### pkg/helper/terraform.go

- **SetupTerraformOptions(t, examplePath, vars)**: Configures Terraform options for tests with isolated provider cache.
  - Parameters:
    - `t`: The testing object for test logging and cleanup functions
    - `examplePath`: Path to the example module (can be relative like "default/basic" or absolute)
    - `vars`: Map of Terraform variables to be passed to the example module
  - Features:
    - Creates an isolated provider cache directory for each test
    - Automatically cleans up the cache after the test completes
    - Handles both absolute and relative paths correctly
    - Sets up appropriate environment variables

- **SetupTargetTerraformOptions(t, moduleName, targetName, vars)**: Configures Terraform options for unit tests that use target directories.
  - Parameters:
    - `t`: The testing object for test logging and cleanup functions
    - `moduleName`: Name of the module being tested (e.g., "default")
    - `targetName`: Name of the target test case (e.g., "basic")
    - `vars`: Map of Terraform variables to be passed to the module
  - Features:
    - Sets up isolated provider cache for clean test execution
    - Automatically resolves paths to the target test directory
    - Provides consistent environment variables

- **SetupModuleTerraformOptions(t, moduleDir, vars)**: Configures Terraform options for testing a module directly.
  - Parameters:
    - `t`: The testing object for test logging and cleanup functions
    - `moduleDir`: Direct path to the module being tested
    - `vars`: Map of Terraform variables to be passed to the module
  - Features:
    - Creates isolated provider cache
    - Uses the module directory directly without path handling to prevent path duplication
    - Disables color output for more consistent test output parsing

- **WaitForResourceDeletion(t, duration)**: Adds a delay to handle eventual consistency in cloud resources.
  - Parameters:
    - `t`: The testing object for logging
    - `duration`: The amount of time to wait (e.g., 30*time.Second)

### Recommended Usage

- **For example tests**: Use `helper.SetupTerraformOptions()` with the example path
  ```go
  terraformOptions := helper.SetupTerraformOptions(t, "default/basic", vars)
  ```

- **For target directory tests**: Use `helper.SetupTargetTerraformOptions()` with module and target names
  ```go
  terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "basic", vars)
  ```

- **For direct module tests**: Use `helper.SetupModuleTerraformOptions()` with the full module path
  ```go
  dirs, err := repo.NewTFSourcesDir()
  require.NoError(t, err)
  terraformOptions := helper.SetupModuleTerraformOptions(t, dirs.GetModulesDir("default"), vars)
  ```

- **For path resolution**: Always use `repo.NewTFSourcesDir()` instead of hardcoding paths
  ```go
  dirs, err := repo.NewTFSourcesDir()
  require.NoError(t, err)
  modulePath := dirs.GetModulesDir("default")
  examplePath := dirs.GetExamplesDir("default/basic")
  targetPath := dirs.GetTargetDir("default", "basic")
  ```

- **For resource cleanup**: Add appropriate delays after resource deletion
  ```go
  terraform.Destroy(t, terraformOptions)
  helper.WaitForResourceDeletion(t, 30*time.Second)
  ```

### Rule: Unit Test Conventions

- ALWAYS add the appropriate build tag at the top of unit test files:
  - For read-only tests: `//go:build readonly && unit`
  - For integration tests: `//go:build integration && unit`
- The build tag MUST be placed at the very top of the file with a blank line after it.
- The mandatory naming convention for unit test files is: `[test-name]_[test-scope]_test.go`, where:
  - `[test-name]`: The target of the test (terraform module) that should match the name of the directory in the `tests/[module-name]/target/[use-case-name]/` directory. E.g.: if the target use case is in the `tests/mymodule/target/enabled_keys/` directory, then the test name is `enabled_keys`.
  - `[test-scope]`: The scope of the test - ONLY VALID VALUES ARE `readonly`, `integration`, where `readonly` means read-only, and `integration` means end-to-end.
- For a same target, if you need both `readonly` and `integration` tests, they should be in separate files with appropriate build tags:

```text
tests/
└── modules/
    └── mymodule/
        └── unit/
            ├── enabled_keys_readonly_test.go  # With build tag: //go:build readonly && unit
            └── enabled_keys_integration_test.go  # With build tag: //go:build integration && unit
```

#### Rule: Examples Tests Conventions

- The `examples` directory should always be created, even if it's empty. It includes tests that use the example modules in the `examples/[module-name]/[example-name]` directory.
- ALWAYS add the appropriate build tag at the top of example test files:
  - For read-only tests: `//go:build readonly && examples`
  - For integration tests: `//go:build integration && examples`
- The build tag MUST be placed at the very top of the file with a blank line after it.
- The mandatory naming convention for example test files is: `[test-name]_[test-scope]_test.go`, where:
  - `[test-name]`: The name of the test that matches the name of the terraform module in the examples directory. E.g.: if the module is in the `examples/mymodule/basic/` directory, then the test name is `basic`.
  - `[test-scope]`: The scope of the test - ONLY VALID VALUES ARE `readonly`, `integration`, where `readonly` means read-only, and `integration` means end-to-end.
- For a same example, if you need both `readonly` and `integration` tests, they should be in separate files with appropriate build tags:

```text
tests/
└── modules/
    └── mymodule/
        └── examples/
            ├── basic_readonly_test.go  # With build tag: //go:build readonly && examples
            └── basic_integration_test.go  # With build tag: //go:build integration && examples
```

- Example test files should be named after the example they're testing, not after the functionality they're testing.

### Rule: Quality of the Tests written (Terratest)

- A Good Example of a test function is (self-explanatory, with nice comments, and verbose):

```go
// TestSanityChecksOnModule verifies that the Terraform module can be initialized and validated successfully.
// It performs the following steps:
// 1. Initializes the Terraform module located in the specified directory.
// 2. Validates the Terraform configuration to ensure it is syntactically valid and ready for deployment.
// This test runs in parallel to allow for efficient execution of multiple tests.
func TestSanityChecksOnModule(t *testing.T) {
	// Parallel execution with unique test names
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Enhanced Terraform options with logging and upgrade
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesDir("default"),
		Upgrade:      true,
	}

	// Detailed logging of module directory
	t.Logf("🔍 Terraform Module Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Validate with detailed error output
	validateOutput, err := terraform.ValidateE(t, terraformOptions)
	require.NoError(t, err, "Terraform validate failed")
	t.Log("✅ Terraform Validate Output:\n", validateOutput)
}
```

- The test functions should be named following the pattern: `Test<Behaviour>On<Scenario>When<Condition>`. E.g.: `TestStaticAnalysisOnExamplesWhenTerraformIsInitialized`, and ensure it's consistent, clear, and ideally short without sacrificing the readability.

```go
// TestInitializationOnModuleWhenUpgradeEnabled verifies that the Terraform module can be successfully initialized
// with upgrade enabled, ensuring compatibility and readiness for deployment.
func TestInitializationOnModuleWhenUpgradeEnabled(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesDir("default"),
		Upgrade:      true,
	}

	t.Logf("🔍 Terraform Module Directory: %s", terraformOptions.TerraformDir)

	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)
}

// TestValidationOnExamplesWhenBasicConfigurationLoaded ensures that the basic example
// configuration passes Terraform validation checks, verifying its structural integrity.
func TestValidationOnExamplesWhenBasicConfigurationLoaded(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
		Upgrade:      true,
	}

	t.Logf("🔍 Terraform Examples Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Validate with detailed error output
	validateOutput, err := terraform.ValidateE(t, terraformOptions)
	require.NoError(t, err, "Terraform validate failed")
	t.Log("✅ Terraform Validate Output:\n", validateOutput)

	// Run terraform fmt check
	fmtOutput, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "fmt", "-recursive", "-check")
	require.NoError(t, err, "Terraform fmt failed")
	t.Log("✅ Terraform fmt Output:\n", fmtOutput)
}

// TestPlanningOnExamplesWhenModuleEnabled verifies the Terraform plan generation
// for the basic example when the module is explicitly enabled.
func TestPlanningOnExamplesWhenModuleEnabled(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
		Upgrade:      true,
		Vars: map[string]interface{}{
			"is_enabled": true,
		},
	}

	t.Logf("🔍 Terraform Examples Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan to show what would be created in examples
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify no changes are planned when module is disabled
	disabledOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
		Upgrade:      true,
	}

	disabledPlanOutput, err := terraform.PlanE(t, disabledOptions)
	require.NoError(t, err, "Terraform plan failed for disabled module")
	t.Log("📝 Terraform Plan Output (Disabled Module):\n", disabledPlanOutput)

	// Cleanup resources after test
	terraform.Destroy(t, terraformOptions)
}

```

### Rule: Example of a Well-Structured Test File

Below is an example of a well-structured integration test file for an example module:

```go
//go:build integration && examples

package examples

import (
	"testing"
	"time"

	"github.com/example/terraform-module/tests/pkg/repo"
	"github.com/example/terraform-module/tests/pkg/helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestDeploymentOnExamplesBasicWhenDefaultFixture verifies the full deployment of
// the basic example with the default fixture (all components enabled).
func TestDeploymentOnExamplesBasicWhenDefaultFixture(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Setup the terraform options with default fixture
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("mymodule/basic"),
		Upgrade:      true,
		VarFiles:     []string{"fixtures/default.tfvars"},
	}

	// Cleanup resources when the test completes
	defer func() {
		terraform.Destroy(t, terraformOptions)
		helper.WaitForResourceDeletion(t, 30*time.Second)
	}()

	t.Logf("🔍 Terraform Example Directory: %s", terraformOptions.TerraformDir)
	t.Logf("📝 Using fixture: fixtures/default.tfvars")

	// Initialize and apply Terraform
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs from Terraform
	output1 := terraform.Output(t, terraformOptions, "output_name_1")
	output2 := terraform.Output(t, terraformOptions, "output_name_2")

	// Verify outputs
	assert.NotEmpty(t, output1, "Output 1 should not be empty")
	assert.NotEmpty(t, output2, "Output 2 should not be empty")

	// Additional verification logic...
}

```

Key elements of a well-structured test file:

1. **Build Tags**: Placed at the very top of the file with a blank line after them.
2. **Package Declaration**: Matches the directory structure (e.g., `package examples` for tests in the examples directory).
3. **Imports**: Organized and grouped logically.
4. **Test Function Documentation**: Clear comment explaining what the test verifies.
5. **Parallel Execution**: Using `t.Parallel()` for efficient test execution.
6. **Resource Cleanup**: Using `defer` to ensure resources are cleaned up after the test.
7. **Detailed Logging**: Providing context about what's being tested.
8. **Clear Assertions**: Using appropriate assertion functions with descriptive error messages.

## Styleguide: Test Implementation Rules

### Rule: Terratest Rules

- IMPLEMENT parallel execution with `t.Parallel()`
- STRUCTURE tests with setup, execution, and validation phases
- INCLUDE detailed logging for troubleshooting

```go
// TestPlanningOnExamplesWhenModuleEnabled verifies the Terraform plan generation
// for the basic example when the module is explicitly enabled.
func TestPlanningOnExamplesWhenModuleEnabled(t *testing.T) {
    // Enable parallel execution
    t.Parallel()

    // Setup phase
    dirs, err := repo.NewTFSourcesDir()
    require.NoError(t, err, "Failed to get Terraform sources directory")

    terraformOptions := &terraform.Options{
        TerraformDir: dirs.GetExamplesDir("default/basic"),
        Vars: map[string]interface{}{
            "is_enabled": true,
        },
    }

    // Log test context
    t.Logf("Testing directory: %s", terraformOptions.TerraformDir)

    // Execution phase
    terraform.InitAndPlan(t, terraformOptions)

    // Validation phase
    // Add assertions here

    // Optional: Cleanup phase
    defer terraform.Destroy(t, terraformOptions)
}
```

- ENSURE each test is independent
- AVOID shared state between tests
- IMPLEMENT proper setup and teardown
- USE `require` package for critical assertions
- IMPLEMENT detailed error messages
- CHOOSE appropriate assertion functions
- CHECK all error returns
- PROVIDE detailed error messages
- USE `require.NoError` for critical operations
- IMPLEMENT proper test cleanup on failure
- LOG detailed information about the failure
- ENSURE tests fail clearly and informatively
- INCLUDE context in error messages
- LOG relevant state information
- PROVIDE actionable error messages
- ENABLE parallel test execution with `t.Parallel()`
- ENSURE tests are independent and can run concurrently
- AVOID shared state that could cause race conditions
- USE unique resource names for parallel tests
- IMPLEMENT random suffixes for resource names
- AVOID resource name collisions


## Styleguide: Test Execution Rules

### Rule: Using Justfile Commands

- USE Justfile commands for test execution
- ALWAYS inspect with `just` the commands that are available, and the options that can be used. For test executions, there are the following commands that are available:

```bash
# 🧪 Run unit tests  - parameters: MOD (E.g. 'aws'), TAGS (E.g. 'examples,readonly'), TYPE (E.g. 'examples'), NOCACHE (E.g. 'true|false'), TIMEOUT (E.g. '60s|5m|1h')
just tf-test-unit

# 🧪 Run unit tests on Nix - parameters: MOD (E.g. 'aws'), TAGS (E.g. 'examples,readonly'), TYPE (E.g. 'examples'), NOCACHE (E.g. 'true|false'), TIMEOUT (E.g. '60s|5m|1h')
just tf-test-unit-nix

# 🧪 Run example tests - parameters: MOD (E.g. 'aws'), TAGS (E.g. 'examples,readonly'), TYPE (E.g. 'examples'), NOCACHE (E.g. 'true|false'), TIMEOUT (E.g. '60s|5m|1h')
just tf-test-examples

# 🧪 Run example tests on Nix - parameters: MOD (E.g. 'aws'), TAGS (E.g. 'examples,readonly'), TYPE (E.g. 'examples'), NOCACHE (E.g. 'true|false'), TIMEOUT (E.g. '60s|5m|1h')
just tf-test-examples-nix

```
