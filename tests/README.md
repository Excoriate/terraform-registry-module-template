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
        ├── examples/       # Example configuration tests
        │   └── basic_readonly_test.go    # Read-only tests for basic example
        │   └── basic_integration_test.go # Integration tests for basic example
        ├── unit/           # Unit test suite
        │   └── module_test.go    # Tests for the module itself
```

## 🚀 Test Execution Workflow

### Using Justfile Commands

The project uses a `Justfile` to provide a consistent, user-friendly test execution interface.

#### Running Tests

```bash
# Run all tests
just tf-tests

# Run tests for a specific module
just tf-tests MOD=<module_name>
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
func TestBasicExampleInitialization(t *testing.T) {
  t.Parallel()

  terraformOptions := &terraform.Options{
    TerraformDir: "examples/default/basic",
    Vars:         map[string]interface{}{
      "is_enabled": true
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
