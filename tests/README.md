# Infrastructure as Code Tests 🧪

This directory contains a number of automated tests that cover the functionality
of the modules that ship with this repository.

## Introduction

We are using [Terratest] for automated tests that are located in the
`tests/` **directory**. Terratest deploys _real_ infrastructure
(e.g., servers) in a _real_ environment (e.g., AWS).

The basic usage pattern for writing automated tests with Terratest is to:

1. Write tests using Go's built-in [package testing]: you create a file ending
   in `_test.go` and run tests with the `go test` command.
2. Use Terratest to execute your _real_ IaC tools (e.g., Terraform, Packer, etc.)
   to deploy _real_ infrastructure (e.g., servers) in a _real_ environment (e.g., AWS).
3. Validate that the infrastructure works correctly in that environment by
   making HTTP requests, API calls, SSH connections, etc.
4. Undeploy everything at the end of the test.

>**Note #1**: Many of these tests create real resources in an AWS account.
That means they cost money to run, especially if you don't clean up after
yourself. Please be considerate of the resources you create and take extra care
to clean everything up when you're done!

>**Note #2**: Never hit `CTRL + C` or cancel a build once tests are running or
the cleanup tasks won't run!


## How to run the tests

This repository comes with a [Taskfile]  that helps you to run the
tests in a convenient way. By default, the tests are divided into two categories:

1. **Unit tests** that are located in the `tests/<modules_name>/unit/` directory.
2. **Integration tests** that are located in the `tests/<modules_name>/integration/` directory.

As it was mentioned above, [Taskfile] is the easiest way to run the tests.
You can run the tests by executing the following command:

This run all the unit tests, using the default values (`module`=default, `recipe`=basic)

```bash
task test-unit
```

This run all the integration tests, using the default values (`module`=default, `recipe`=basic)

```bash
task test-integration
```

Tests can be run with or without cache. For the **nocache** version of these tests, run:

```bash
task test-unit-nocache
```

```bash
task test-integration-nocache
```

If it's required to test an specific module, with an specific recipe, these two input variables (of the main [Taskfile]) should be set:

* `MODULE`: The name of the module to test. It should be the name of the directory where the module is located.
* `RECIPE`: The name of the recipe to test. It should be the name of the directory where the recipe is located.

>**NOTE**: The _recipe_ refers to the example module beneath the `examples/` directory.
E.g.:

```bash
task MODULE=ec2 RECIPE=instance test-unit
```


## Tests structure

The **tests** structure is described as follows:

```text
tree tests/
tests/
├── README.md
├── TaskFile.yml
└── default
    ├── integration
    │   ├── default_basic_integration_test.go
    │   ├── go.mod
    │   ├── go.sum
    │   └── target
    │       └── basic
    │           └── main.tf
    └── unit
        ├── default_basic_unit_test.go
        ├── go.mod
        ├── go.sum
        └── target
            └── basic
                └── main.tf
```

Important things to note:

* The `TaskFile.yml` file is used to run the tests. It's "smart enough" to — by convention — discover the tests, and execute them.
* The convention for the test discovery is described in the following table:

| Component         | Description                                                                                                                                                                                                                                                                                             | Pattern or convention                                                                                                                       |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| Test `src` folder | Nothing. It's auto-discovered. By convention, all tests are placed under the directory **tests/**                                                                                                                                                                                                       | `tests`, since it includes 1-N tests                                                                                                        |
| Test module       | A given `go.mod` that pairs with a given **terraform module**. Each **terraform** module will have its corresponding `tests/<module>` test module, written in Go, and programatically expressed in a [Go module](https://go.dev/blog/using-go-modules)                                                  | `tests/<module>` (Go code) pairs with `modules/<module>` (Terraform code)                                                                   |
| Recipe            | It's a set of **implementations** that show-case a given module. Are usually known as "example(s)" within OSS module repositories. This part plays a critical role within the auto-discovery of tests, since it also refers to the specific **TestName** convention that your `Go` code should respect. | Recipe name: `basic` should match with the third part of the naming convention of the (Go code) Terratest tests. E.g.: `TestDefaultBasic()` |

## Convention for naming tests in Terratest

* The first part represents the `module`, e.g.: `default`
* The second part represents the `recipe`, e.g.: `basic`
* The third part represents the `test type`, e.g.: `unit` or `integration`
* The fourth part represents the `test name`, e.g.: `IsSomethingDisabled`
Which means, we'd have a valid (and discoverable) IAC test coded as:

```go
func TestDefaultBasicUnitIsDisabled(t *testing.T) {
  t.Parallel()

  terraformOptions := &terraform.Options{
    TerraformDir: "target/basic",
    Vars:         getInputVarsValues(t, false),
    Upgrade:      false,
  }

  terraform.Init(t, terraformOptions)

  terraform.Plan(t, terraformOptions)
}

```

If this convention is respected, the test will be auto-discovered and executed using the `TaskFile.yml` file, without any extra code, just passing the required input variables:

```bash
# Using default values
task test-integration-nocache

```

Or, as it was explained above, it can be customised by passing the `MODULE` and `RECIPE` input variables:

```bash
task MODULE=ec2 RECIPE=instance test-integration-nocache
```

<!-- References -->

<!-- markdown-link-check-disable -->
[terratest]: https://github.com/gruntwork-io/terratest
[package testing]: https://golang.org/pkg/testing/
[Taskfile]: https://taskfile.dev/#/

<!-- markdown-link-check-enable -->
