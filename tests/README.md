# Infrastructure as Code Testing Framework 🧪

## 📘 Testing Philosophy

This directory contains a comprehensive testing framework for Terraform modules, designed to:
- Validate infrastructure code reliability
- Ensure module functionality across different scenarios
- Provide confidence in infrastructure deployments
- Demonstrate module usage patterns

## 🏗️ Testing Approach

### Terratest-Driven Testing

We utilize [Terratest](https://github.com/gruntwork-io/terratest), a Go-based testing framework that:
- Deploys real infrastructure
- Validates resource configurations
- Supports complex infrastructure testing scenarios

### Testing Levels

1. **Examples Tests** (`tests/<module>/examples/`)
   - Validate example configurations
   - Ensure examples can be initialized and planned
   - Verify basic module functionality through examples
   - Includes tests for:
     * Module enabled state
     * Module disabled state
     * Configuration validation

2. **Unit Tests** (`tests/<module>/unit/`)
   - Validate module logic and configuration
   - Lightweight, fast execution
   - Focus on module-specific behaviors

### Testing Benefits

1. **Enhanced Isolation**
   - Each test runs with its own isolated Terraform provider cache
   - Tests can run in parallel without resource conflicts
   - Cleaner test output with independent state

2. **Path Handling**
   - Automatic path resolution for modules, examples, and test targets
   - Support for both absolute and relative paths
   - Prevents path duplication issues and improves reliability

3. **Resource Management**
   - Automatic cleanup of temporary resources
   - Support for waiting periods after resource deletion
   - Consistent environment variables across tests

## 📂 Directory Structure

```text
tests/
├── README.md               # Testing documentation
├── go.mod                  # Go module dependencies
├── go.sum                  # Dependency lockfile
├── pkg/                    # Shared testing utilities
│   ├── repo/               # Repository path utilities
│   │   └── finder.go       # Path resolution functions
│   └── helper/             # Helper utilities
│       ├── resources.go    # Resources utilities
│       └── terraform.go    # Terraform test configuration helpers
└── modules/                # Module-specific test suites
    └── <module_name>/      # Tests for specific module
        ├── examples/       # Example configuration tests
        │   ├── basic_readonly_test.go    # Read-only tests for basic example
        │   └── basic_integration_test.go # Integration tests for basic example
        ├── target/         # Test-specific Terraform configurations
        │   ├── basic/      # Basic configuration for unit tests
        │   │   └── main.tf # Terraform configuration for unit tests
        │   └── disabled_module/  # Configuration for disabled state tests
        │       └── main.tf # Terraform configuration with module disabled
        └── unit/           # Unit test suite
            ├── basic_readonly_test.go    # Read-only unit tests for basic configuration
            └── basic_integration_test.go # Integration unit tests for basic configuration
```

## 🚀 Test Execution Workflow

### Using Justfile Commands

The project uses a `Justfile` to provide a consistent, user-friendly test execution interface.

#### Running Tests

```bash
# Run all readonly tests for the default module
just tf-test-unit

# Run examples tests with specified parameters
just tf-test-examples MOD=default TAGS=readonly NOCACHE=true TIMEOUT=60s

# Run integration tests for a specific module
just tf-test-unit MOD=mymodule TAGS=integration
```

### Helper Function Usage

The tests use specialized helper functions to simplify test setup and ensure isolation:

1. **SetupTerraformOptions** - For testing example implementations:
   ```go
   terraformOptions := helper.SetupTerraformOptions(t, "default/basic", map[string]interface{}{
      "is_enabled": true,
   })
   ```

2. **SetupTargetTerraformOptions** - For unit tests using target directories:
   ```go
   terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "basic", map[string]interface{}{
      "is_enabled": true,
   })
   ```

3. **SetupModuleTerraformOptions** - For testing modules directly:
   ```go
   dirs, err := repo.NewTFSourcesDir()
   require.NoError(t, err)
   terraformOptions := helper.SetupModuleTerraformOptions(t, dirs.GetModulesDir("default"), map[string]interface{}{
      "is_enabled": true,
   })
   ```

### Test Execution Variants

1. **Local Execution**
   - Uses local development environment
   - Fastest test runner
   - Requires local Go and Terraform installations

2. **Nix Development Environment**
   ```bash
   # Run tests in reproducible Nix environment
   just tf-test-unit-nix
   just tf-test-examples-nix
   ```

## 💡 Best Practices

### Writing Tests

- Use descriptive test function names in the format `Test<Behaviour>On<Target>When<Condition>`
- Enable parallel test execution with `t.Parallel()`
- Use the appropriate helper function for your test type
- Always clean up resources after tests
- Leverage isolated provider caches for independence

### Test Function Example

```go
// TestInitializationOnBasicExampleWhenModuleEnabled verifies that the basic
// example can be initialized with the module enabled.
func TestInitializationOnBasicExampleWhenModuleEnabled(t *testing.T) {
  t.Parallel()

  // Set up test with isolated provider cache
  terraformOptions := helper.SetupTerraformOptions(t, "default/basic", map[string]interface{}{
    "is_enabled": true,
  })

  // Log the test context
  t.Logf("Testing example at: %s", terraformOptions.TerraformDir)

  // Initialize and validate the configuration
  terraform.InitAndValidate(t, terraformOptions)
}
```

## 🔍 Continuous Integration

Tests are integrated into the project's CI workflow:
- Automatically run on pull requests
- Validate module functionality
- Ensure code quality

## 🛠️ Test Development Utilities

### Shared Testing Utilities (`pkg/`)

Provides common testing helper functions:
- Repository path resolution
- Infrastructure testing support

## 🔒 Security Considerations

- Tests run with minimal privileges
- Avoid hardcoding sensitive information
- Use environment-specific configurations

## 🔄 Continuous Improvement

- Regularly update test coverage
- Review and refactor test suites
- Incorporate feedback from CI/CD pipeline

## 📚 References

- [Terratest Documentation](https://terratest.gruntwork.io/)
- [Go Testing Package](https://golang.org/pkg/testing/)
- [Terraform Testing Strategies](https://www.terraform.io/docs/extend/testing/index.html)

**Note:** Effective testing is crucial for maintaining infrastructure reliability and code quality.
