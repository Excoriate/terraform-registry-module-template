<h1 align="center">
  <img alt="logo" src="https://forum.huawei.com/enterprise/en/data/attachment/forum/202204/21/120858nak5g1epkzwq5gcs.png" width="224px"/><br/>
  Terraform AWS ☁️ [Your module name]
</h1>
<p align="center">An easy to understand, opinionated terraform <b>composable</b> module<b> for AWS ☁️</b>.<br/><br/>

---

[![Auto Release](https://github.com/Excoriate/vault-labs/actions/workflows/release.yml/badge.svg)](https://github.com/Excoriate/vault-labs/actions/workflows/release.yml)
[![Terraform Check](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/ci-check-terraform.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/ci-check-terraform.yml)
[![Run pre-commit](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/ci-check-precommit.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/ci-check-precommit.yml)
[![Terratest](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/ci-pr-terratest.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/ci-pr-terratest.yml)

[//]: # (// FIXME: Remove, refactor or change. (Template)

## Table of Contents
1. [About The Module](#about-the-module)
2. [Module documentation](#module-documentation)
   1. [Capabilities](#capabilities)
   2. [Getting Started](#getting-started)
   3. [Roadmap](#roadmap)
   4. [Module standard structure](#module-standard-structure)
3. [Developer Experience](#developer-experience)
   1. [Tools used](#tools-used)
   2. [Configuring AWS credentials for local development](#configuring-aws-credentials-for-local-development)
   3. [Running common development actions](#running-common-actions-for-local-development)
   4. [Running tests](#tests)
4. [Contributions](#contributing)
5. [License](#license)
6. [Contact](#contact)



<!-- ABOUT THE PROJECT -->
## About The Module
[//]: # (// FIXME: Remove, refactor or change. (Template)
(put high level description here)

---


## Module documentation
The documentation is **automatically generated** by [terraform-docs](https://terraform-docs.io), and it's available in the module's [README.md](modules/default/README.md) file.
### Capabilities
[//]: # (// FIXME: Remove, refactor or change. (Template)

(put description here)
### Getting Started
[//]: # (// FIXME: Remove, refactor or change. (Template)

(put description here)
### Roadmap
[//]: # (// FIXME: Remove, refactor or change. (Template)

(put description here)

### Module standard structure
The module's relevant components, structure and "skeleton" is described below:
```txt
├── README.md
├── TaskFile.yml
├── docs
│   └── contribution_guidelines.md
├── examples
│   ├── README.md
│   ├── TaskFile.yml
│   └── default
│       └── basic
│           ├── README.md
│           ├── config
│           │   └── fixtures.tfvars
│           ├── main.tf
│           ├── providers.tf
│           ├── variables.tf
│           └── versions.tf
├── modules
│   ├── TaskFile.yml
│   └── default
│       ├── README.md
│       ├── data.tf
│       ├── locals.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── versions.tf
├── pre-commit-config-githubactions.yaml
└── tests
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
Where:
* **⚡️Modules**: refers to the actual module's directory. Where the `.tf` files reside. Each `subdirectory` is a module.
* **⚡️Examples**: refers to the examples directory, where the examples recipes lives. These are also used for testing the infrastructure using [Terratest](https://terratest.gruntwork.io/). For its specific documentation, query [this link](examples/README.md)
* **⚡️Tests**: refers to the tests directory, where the tests recipes lives. These are also used for testing the infrastructure using [Terratest](https://terratest.gruntwork.io/). For its specific documentation, query [this link](tests/README.md)

## Developer Experience
Some tools that this repo uses:
- 🧰 Terraform — strongly recommended the latest versions
- 🧰 Go — justified mostly for **[Terratest](https://terratest.gruntwork.io/)**
- 🧰 [TaskFile](https://taskfile.dev/#/) — for the automation of the tasks.
>**NOTE**: For automation during the development process, I use [precommit](https://pre-commit.com/), which is a framework for managing and maintaining multi-language pre-commit hooks. It's a great tool, and I highly recommend it. All the hooks required are installed by [this](./DevEx/scripts/hooks/install-pre-commit-hooks-deps.sh) script. It's recommended though to run it through the [TaskFile](./TaskFile.yml) task `pre-commit-init`.

To initialize your pre-commit configuration, and ensure all the hooks are installed, run the following command:
```bash
task pre-commit-init
```
To run these hooks against all the files, you can use the following `Task` command:
```bash
task pre-commit
```

### Configuring AWS credentials for local development
For sure you've seen that in the main Taskfile, there's a task called `gen-env-aws`. That task aims to generate a proper `.env.<env>.aws` **dotEnv** file which is used by the `TaskFile.yml` tasks. If you have a proper AWS credentials file, you can run the following command:
```bash
task gen-env-aws
```
In simple terms, that tasks (which runs a shell script) scan your pre-existing AWS profiles, and generate the `.env.<env>.aws` file for you. When it's generated, running a task that wraps a terraform command, will use the generated `.env.<env>.aws` file to set the proper AWS credentials. For example:
```bash
# dev refers to the environment selected, which's how the file is also named. E.g.: env.dev.aws
ENV=dev task module-plan
```

### Running common actions for local development
Run unit tests (wrapping [Terratest](https://terratest.gruntwork.io/)):
```bash
# If you want to list the available tasks.
task list
# Run the unit tests.
task test-unit
```

Run integration tests — if exists (wrapping [Terratest](https://terratest.gruntwork.io/)):
```bash
# If you want to list the available tasks.
task list
# Run the unit tests.
task test-integration
```

Run all the configured **pre-commit** hooks (forcing them to run on all files):
```bash
task pre-commit
```

Run a vanilla terraform plan over the `example/basic` (recipe) example:
```bash
# No arguments are required, since it's using its defaults: example as the module's name, and basic as its recipe's name.
task recipe-plan
```

### Tests
See the detailed documentation [here](./tests/README.md).


---

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## Contributing

Contributions are always encouraged and welcome! ❤️. For the process of accepting changes, please refer to the [CONTRIBUTING.md](./CONTRIBUTING.md) file, and for a more detailed explanation, please refer to this guideline [here](docs/contribution_guidelines.md).

## License

![license][badge-license]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

## Contact
- 📧 **Email**: [Alex T.](mailto:alex@ideaup.cl)
- 🧳 **Linkedin**: [Alex T.](https://www.linkedin.com/in/alextorresruiz/)

_made/with_ ❤️  🤟


<!-- References -->
[LICENSE]: ./LICENSE
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[Semantic Versioning (SemVer)]: https://semver.org/
