# Example "Recipes" 🥗

The example recipes are located in the `examples/` directory. These are also used for testing the infrastructure using [terratest], nonetheless, they are meant to run independently and be checked directly using _vanilla_ terraform commands.

## Example's structure

The example's structure is described below:

```txt
tree examples/
examples/
├── README.md
└── [module-name]/
    └── [example-name]/ # e.g., default/basic or default/complete
        ├── README.md
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── providers.tf
        ├── versions.tf
        ├── .terraform-docs.yml
        ├── .tflint.hcl
        └── fixtures/
            ├── default.tfvars
            └── disabled.tfvars
            # Other fixture files as needed
```

>**NOTE**: The parent directory `examples/` includes all the **examples** (previously referred to as recipes). For a module named `default`, you would typically find examples under `examples/default/basic/`, `examples/default/complete/`, etc. The `basic` example represents the fundamental usage of the module.

## Running Examples

Use [Justfile] for doing so. The `Justfile` is located in the root of the repo, and it's used for running the examples. The `Justfile` recipes related to these examples are customizable by passing arguments directly to the `just` command. Key parameters include:

* `MODULE`: The module's name (directory name under `modules/` and `examples/`). Default: `default`.
* `EXAMPLE`: The example's name (directory name under `examples/<MODULE>/`). Default: `basic`.
* `FIXTURE`: The name of the fixture file (e.g., `default.tfvars`, `disabled.tfvars`) located in the `examples/<MODULE>/<EXAMPLE>/fixtures/` directory. Default: `default.tfvars`.
* `CLEAN`: Whether to clean Terraform cache files before execution. Default: `false`.

Common `Justfile` recipes to run examples:

**Initialize, Validate, and Plan an Example:**
This command performs static analysis on the module, initializes both the module and the specified example, validates the example's configuration, and then generates a plan using the specified fixture file.
```bash
just tf-dev MODULE="default" EXAMPLE="basic" FIXTURE="default.tfvars"
```

**Full Lifecycle (Init, Validate, Plan, Apply, Destroy) of an Example:**
This command executes the full lifecycle: all steps from `tf-dev`, followed by `terraform apply` and `terraform destroy` for the specified example and fixture.
```bash
just tf-dev-full MODULE="default" EXAMPLE="basic" FIXTURE="default.tfvars"
```

You can find more details and other available recipes by running `just --list` or inspecting the `Justfile` directly.


<!-- References -->

<!-- markdown-link-check-disable -->
[terratest]: https://github.com/gruntwork-io/terratest
[Justfile]: https://github.com/casey/just

<!-- markdown-link-check-enable -->
