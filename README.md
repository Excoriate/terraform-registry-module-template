<h1 align="center">
  <img alt="logo" src="https://forum.huawei.com/enterprise/en/data/attachment/forum/202204/21/120858nak5g1epkzwq5gcs.png" width="224px"/><br/>
  Terraform Module Golden Template 🏆
</h1>
<p align="center">An easy to understand, opinionated terraform <b>composable</b> module<b> with batteries included 🔋</b>.<br/><br/>

---

[![Unit & Integration tests TerraTest](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/terratest.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/terratest.yml)
[![Go Linter Terratest](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/golang-linter-terratest.yaml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/golang-linter-terratest.yaml)
[![Release](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/release.yaml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/release.yaml)
[![Terraform CI Checks Modules](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/terraform-ci-modules.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/terraform-ci-modules.yml)
[![Terraform CI Checks Recipes](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/terraform-ci-recipes.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/terraform-ci-recipes.yml)
[![Terraform Plan recipes](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/terraform-plan-recipes.yml/badge.svg)](https://github.com/Excoriate/terraform-registry-module-template/actions/workflows/terraform-plan-recipes.yml)

[//]: # (// FIXME: Remove, refactor or change. (Template)


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
.
├── CONTRIBUTING.md
├── LICENSE
├── Makefile
├── README.md
├── TaskFile.yml
├── default
│   └── unit
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
│           ├── outputs.tf
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
├── release-please-config.json
├── scripts
│   ├── containers
│   │   └── build-and-run.sh
│   ├── golang
│   │   └── go_build.sh
│   └── hooks
│       └── pre-commit-init.sh
├── taskfiles
│   ├── Taskfile.common.yml
│   ├── Taskfile.devex.yml
│   ├── Taskfile.precommit.yml
│   ├── Taskfile.terraform.yml
│   └── Taskfile.terragrunt.yml
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
                    └── main.tf```
```

Where:

* **⚡️Modules**: refers to the actual module's directory. Where the `.tf` files reside. Each `subdirectory` is a module.
* **⚡️Examples**: refers to the examples directory, where the examples recipes lives. These are also used for testing the infrastructure using [Terratest](https://terratest.gruntwork.io/). For its specific documentation, query [this link](examples/README.md)
* **⚡️Tests**: refers to the tests directory, where the tests recipes lives. These are also used for testing the infrastructure using [Terratest](https://terratest.gruntwork.io/). For its specific documentation, query [this link](tests/README.md)

## Developer Experience

Some tools that this repo uses:

* 🧰 Terraform — strongly recommended the latest versions
* 🧰 Go — justified mostly for **[Terratest](https://terratest.gruntwork.io/)**
* 🧰 [TaskFile](https://taskfile.dev/#/) — for the automation of the tasks.
* 🧰 [Make](https://www.gnu.org/software/make/) — for the automation of the tasks.

>**NOTE**: For automation during the development process, I use [precommit](https://pre-commit.com/), which is a framework for managing and maintaining multi-language pre-commit hooks. It's a great tool, and I highly recommend it. All the hooks required are installed by [this](./DevEx/scripts/hooks/install-pre-commit-hooks-deps.sh) script. It's recommended though to run it through the [TaskFile](./TaskFile.yml) task `pre-commit-init`.

To initialize your pre-commit configuration, and ensure all the hooks are installed, run the following command:

```bash
# Using taskFiles
task pc-init
# Using make
make pc-init
```

To run these hooks against all the files, you can use the following `Task` command:

```bash
# Using taskFiles
task pc-run
# Using make
make pc-run
```

---

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

* Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
* Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

>**NOTE**: The releases are automatically generated using [release-please-action](https://github.com/google-github-actions/release-please-action). For more information, please refer to the [release-please-action documentation](https://github.com/google-github-actions/release-please-action)

## Contributing

Contributions are always encouraged and welcome! ❤️. For the process of accepting changes, please refer to the [CONTRIBUTING.md](./CONTRIBUTING.md) file, and for a more detailed explanation, please refer to this guideline [here](docs/contribution_guidelines.md).

## License

![license][badge-license]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

## Contact

* 📧 **Email**: [Alex T.](mailto:alex@ideaup.cl)
* 🧳 **Linkedin**: [Alex T.](https://www.linkedin.com/in/alextorresruiz/)

_made/with_ ❤️  🤟


<!-- References -->
[LICENSE]: ./LICENSE
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[Semantic Versioning (SemVer)]: https://semver.org/
