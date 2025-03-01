# Unit Tests for Default Module

This directory contains read-only unit tests for the default Terraform module. These tests validate the module's configuration without applying any resources.

## Test Files

- `basic_readonly_test.go`: Tests for the basic module configuration
- `disabled_module_readonly_test.go`: Tests for the module when it's disabled
- `tags_readonly_test.go`: Tests for the module with custom tags
- `outputs_readonly_test.go`: Tests for the module outputs

## Running the Tests

To run all unit tests:

```bash
cd tests
go test -v -tags=unit,readonly ./modules/default/unit/...
```

To run a specific test file:

```bash
cd tests
go test -v -tags=unit,readonly ./modules/default/unit/basic_readonly_test.go
```

To run a specific test function:

```bash
cd tests
go test -v -tags=unit,readonly ./modules/default/unit/... -run TestPlanningOnTargetWhenModuleEnabled
```

## Test Tags

These tests use the following build tags:

- `unit`: Identifies these as unit tests
- `readonly`: Indicates that these tests don't apply any resources

## Test Coverage

These unit tests cover:

1. Module initialization and validation
2. Plan generation for enabled and disabled module configurations
3. Verification of custom tags
4. Validation of module outputs

## Notes

- These tests are read-only and don't create any actual resources
- They use the target configurations in `tests/targets/default/basic` and `tests/targets/default/disabled_module`
- The tests verify that the module behaves as expected when enabled or disabled
- They also validate that tags are properly passed to resources and outputs 
