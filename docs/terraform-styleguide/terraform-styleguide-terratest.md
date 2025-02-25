# Terraform Terratest StyleGuide: Mandatory Testing Standards and Practices

## Table of Contents

- [Terraform Terratest StyleGuide: Mandatory Testing Standards and Practices](#terraform-terratest-styleguide-mandatory-testing-standards-and-practices)
  - [Table of Contents](#table-of-contents)
  - [Purpose and Scope](#purpose-and-scope)
  - [Styleguide: Fundamental Principles of Terraform Testing](#styleguide-fundamental-principles-of-terraform-testing)
    - [Rule: Testing Philosophy](#rule-testing-philosophy)
    - [Rule: Testing Approach](#rule-testing-approach)
  - [Styleguide: Test Structure Rules](#styleguide-test-structure-rules)
    - [Rule: Test Directory Layout](#rule-test-directory-layout)
    - [Rule: Target Terraform Configuration in the Test Directory](#rule-target-terraform-configuration-in-the-test-directory)
    - [Rule: Test File Creation, and Organization.](#rule-test-file-creation-and-organization)
    - [Rule: Test Naming Conventions](#rule-test-naming-conventions)
  - [Styleguide: Unit Testing Rules](#styleguide-unit-testing-rules)
    - [Rule: Module Unit Tests](#rule-module-unit-tests)
  - [Styleguide: Test Implementation Rules](#styleguide-test-implementation-rules)
    - [Rule: Test Function Structure](#rule-test-function-structure)
  - [Styleguide: Test Utilities](#styleguide-test-utilities)
    - [Rule: Repository Path Resolution](#rule-repository-path-resolution)
  - [Styleguide: Test Execution Rules](#styleguide-test-execution-rules)
    - [Rule: Using Justfile Commands](#rule-using-justfile-commands)

## Purpose and Scope

This document provides comprehensive guidelines for implementing tests for Terraform modules using Terratest, ensuring consistent, reliable, and maintainable test suites that validate module functionality and serve as executable documentation.

## Styleguide: Fundamental Principles of Terraform Testing

### Rule: Testing Philosophy

- ENSURE tests validate both resource creation and configuration of the target module.
- SIMPLE tests, that always test two things:
  - The module's configuration, and its features, by testing the examples in the `examples/[module-name]/[example-type]/*.tf` modules (e.g. `basic`, `complete`, `minimal`, etc.)
  - Unit tests that validate particular features, or behaviors, of the module. The sources of these tests are located in the `tests/modules/[module-name]/target` directory.
- ALWAYS use the latest version of Terratest, and the latest version of Terraform.

### Rule: Testing Approach

- The tests targets are always two:
  1. The module's configuration, and its features, by testing the examples in the `examples/[module-name]/[example-type]/*.tf` modules (e.g. `basic`, `complete`, `minimal`, etc.).
  2. Unit tests that validate particular features, or behaviors, of the module. The sources of these tests are located in the `tests/[module-name]/target` directory. If this directory does not exist, create it, and call it `target/[use-case-name]`.
- Keep tests simple, readable, and maintainable. Use the [terratest](https://terratest.gruntwork.io/) framework to its fullest extent.

## Styleguide: Test Structure Rules

### Rule: Test Directory Layout

- FOLLOW this structure for all test implementations:

```text
tests/
├── README.md               # Testing documentation
├── go.mod                  # Go module dependencies
├── go.sum                  # Dependency lockfile
├── pkg/                    # Shared testing utilities
│   └── repo/               # Repository path utilities
│       └── finder.go       # Path resolution functions
└── modules/                # Module-specific test suites
    └── <module_name>/      # Tests for specific module
        ├── target/         # Use-case specific test suite
        │   └── <use-case-name>/    # Use-case specific test suite
        │   └── main.tf         # Terraform configuration for the use-case
        ├── unit/           # Unit test suite
        │   ├── module_test.go    # Tests for the module itself
        │   └── examples_test.go  # Tests for the module's examples
        │   └── features_test.go  # Tests for the module's features. These tests runs against the target module(s)
        └── integration/    # Integration test suite (when needed)
            ├── module_test.go
            └── examples_test.go
```

- Boilerplate code that's always included in every test implementation:
  - `go.mod` and `go.sum` files, to manage the dependencies, since the Go modules are always created in advance.
  - `pkg/` directory, to manage the shared testing utilities. More utilities shared by all tests will be added incrementally.
  - `modules/` directory, to manage the module-specific test suites per module located in the `modules/[module-name]/` directory.
  - `target/` directory, to manage the use-case specific test suites. These are ad-hoc terraform configurations that uses the module in the `modules/[module-name]/` directory, to test particular (hence, units) features, and capabilities of the  module. The path should be always relative to the `modules/[module-name]/` directory. E.g.: `modules/[module-name]/target/[use-case-name]/*.tf`.

### Rule: Target Terraform Configuration in the Test Directory

The purpose of these configurations is to be used for unit testing purposes

- ALWAYS create the `tests/modules/[module-name]/target/basic/main.tf`, to manage the terraform configuration for the use-case, that's the most basic, and default one. Mimic the configuration placed in the `examples/[module-name]/basic/main.tf` file, as a good starting point, and reference. Nevertheless, ALSO CHECK the `variables.tf` file, and the `outputs.tf` file, to ensure the use-case is properly configured (from the `modules/[module-name]/variables.tf` and `modules/[module-name]/outputs.tf` files).
- ALWAYS call the first target unit-test module `basic`, so if you're creating a new target unit-test module, name it `tests/modules/[module-name]/target/basic/main.tf`.
- NAME the module reference as `this`, and not `[module-name]_test` in the `tests/modules/[module-name]/target/[use-case-name]/main.tf` file.
- OPTIONALLY, create `variables.tf`, and other `*.tf` configuration files, ONLY if they're required by the unit tests.

### Rule: Test File Creation, and Organization.

- ALWAYS create the `tests/modules/[module-name]/unit/module_test.go`, to manage the unit tests for the module itself. This test is a simple `terraform init` check on the `modules/[module-name]/` directory. E.g.:

```go
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

- ALWAYS create the `examples_basic_test.go`, to test through terratest the `examples/[module-name]/basic`  example module. Here's an example implementation:
- The unit tests of the configurations in the `tests/modules/[module-name]/target/[use-case-name]`, MUST all be written in the `tests/modules/[module-name]/unit/features_test.go` file (a file with a set of unit tests, all run against the `tests/modules/[module-name]/target/[use-case-name]` target module).

```go
func TestStaticAnalysisOnExamples(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Enhanced Terraform options with logging and upgrade
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
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

	// Run terraform fmt check
	fmtOutput, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "fmt", "-recursive", "-check")
	require.NoError(t, err, "Terraform fmt failed")
	t.Log("✅ Terraform fmt Output:\n", fmtOutput)
}

func TestPlanOnExamples(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Enhanced Terraform options with logging and upgrade
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
		Upgrade:      true,

		// Optional: Add vars for more comprehensive testing
		Vars: map[string]interface{}{
			"is_enabled": true,
		},
	}

	// Detailed logging of module directory
	t.Logf("🔍 Terraform Examples Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Optional: Plan to show what would be created in examples
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Optional: Verify no changes are planned when module is disabled
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

- Whenever you are creating a new tests, always verify the interfaces of the `modules/[module-name]/` directory, and the `examples/[module-name]/[example-type]/*.tf` files, to ensure the use-case is properly configured (interfaces, are the variables, and outputs of the module).


### Rule: Test Naming Conventions

- PREFIX all test functions with `Test`
- USE descriptive names that indicate what is being tested
- USE always, Go Docs (verbose) for each Test Function, to explain what the test is verifying.
- FOLLOW this pattern: `Test<Module><Feature><Scenario>`.

An example of well-crafted test names, and test functions are:

```go
// Compliant Names
// TestDefaultModuleWithEnabledFlag verifies that the default module behaves correctly
// when the enabled flag is set. It checks that all expected resources are created
// and that the module initializes without errors.
func TestDefaultModuleWithEnabledFlag(t *testing.T) { ... }

// TestBasicExampleStaticAnalysis ensures that the basic example configuration passes
// static analysis checks. This includes verifying that the Terraform code is valid
// and adheres to best practices.
func TestBasicExampleStaticAnalysis(t *testing.T) { ... }

// Non-Compliant Names (Avoid)
// TestFunction1 is a placeholder test function that does not provide any meaningful
// context about what is being tested. It should be avoided in favor of more descriptive
// test names that clearly indicate the purpose of the test.
func TestFunction1(t *testing.T) { ... }

// TestBasic is a vague test function name that does not specify what aspect of the
// module or functionality is being tested. It is important to use descriptive names
// to improve test readability and maintainability.
func TestBasic(t *testing.T) { ... }
```

- USE descriptive variable names
- FOLLOW Go naming conventions, and the Go effective practices.
- MAINTAIN consistency with module variable names
- USE lowercase with underscores for all file names
- FOLLOW standard Go test file naming (`*_test.go`)
- ENSURE file names reflect their purpose

## Styleguide: Unit Testing Rules

### Rule: Module Unit Tests

- VERIFY module initialization succeeds
- VALIDATE module structure and configuration
- ENSURE module passes static analysis

```go
func TestSanityChecksOnModule(t *testing.T) {
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

    validateOutput, err := terraform.ValidateE(t, terraformOptions)
    require.NoError(t, err, "Terraform validate failed")
}
```

- TEST module behavior with feature flags enabled and disabled
- VERIFY conditional resource creation works as expected
- VALIDATE module handles edge cases properly
- TEST module with various input combinations
- VERIFY validation rules work as expected
- CONFIRM default values are applied correctly

## Styleguide: Test Implementation Rules

### Rule: Test Function Structure

- IMPLEMENT parallel execution with `t.Parallel()`
- STRUCTURE tests with setup, execution, and validation phases
- INCLUDE detailed logging for troubleshooting

```go
func TestExampleStructure(t *testing.T) {
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

## Styleguide: Test Utilities

### Rule: Repository Path Resolution

- USE the `repo` package for path resolution, and other utilities, and packages that are available in the `pkg/` directory.
- AVOID hardcoded paths, unless it's strictly necessary.
- IMPLEMENT reusable helper functions in the `pkg` directory
- SHARE common test logic across test files

## Styleguide: Test Execution Rules

### Rule: Using Justfile Commands

- USE Justfile commands for test execution


```bash
# Run unit tests for a specific module
just tf-tests MOD=default

# Run unit tests
just tf-tests MOD=default TYPE=unit
```
