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

1. **Unit Tests** (`tests/<module>/unit/`)
   - Validate module logic and configuration
   - Lightweight, fast execution
   - Focus on module-specific behaviors

2. **Integration Tests** (`tests/<module>/integration/`)
   - Test module interactions with real infrastructure
   - Validate end-to-end module functionality
   - Simulate production-like scenarios

## 📂 Directory Structure

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

## 🚀 Test Execution Workflow

### Using Justfile Commands

The project uses a `Justfile` to provide a consistent, user-friendly test execution interface.

#### Unit Tests

```bash
# Run all unit tests (default module)
just tf-tests

# Run unit tests for a specific module
just tf-tests MOD=<module_name>
```

#### Integration Tests

```bash
# Run integration tests (default module)
just tf-tests TYPE=integration

# Run integration tests for a specific module
just tf-tests MOD=<module_name> TYPE=integration
```

### Test Execution Variants

1. **Local Execution**
   - Uses local development environment
   - Fastest test runner
   - Requires local Go and Terraform installations

2. **Nix Development Environment**
   ```bash
   # Run tests in reproducible Nix environment
   just tf-tests-nix
   just tf-tests-nix MOD=<module_name> TYPE=integration
   ```

## 💡 Best Practices

### Writing Tests

- Use descriptive test function names
- Cover multiple scenarios (enabled/disabled states)
- Validate resource attributes
- Test error conditions
- Clean up resources after tests

### Test Function Example

```go
func TestDefaultBasicUnitIsDisabled(t *testing.T) {
  t.Parallel()

  terraformOptions := &terraform.Options{
    TerraformDir: "target/basic",
    Vars:         map[string]interface{}{
      "is_enabled": false
    },
  }

  terraform.Init(t, terraformOptions)
  terraform.Plan(t, terraformOptions)
}
```

## 🔍 Continuous Integration

Tests are integrated into the project's CI workflow:
- Automatically run on pull requests
- Validate module functionality
- Ensure code quality

## 🛠️ Test Development Utilities

### Shared Testing Utilities (`pkg/testutils`)

Provides common testing helper functions:
- Input validation
- Resource state checking
- Mock infrastructure generation

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
