# Example "Recipes" 🥗
The example recipes are located in the `examples/` directory. These are also used for testing the infrastructure using [terratest], nonetheless, they are meant to run independently and be checked directly using _vanilla_ terraform commands.

## Recipe's structure
The recipe's structure is described below:
```txt
tree examples/
examples/
├── README.md
├── TaskFile.yml
└── default
    └── basic
        ├── README.md
        ├── config
        │   └── fixtures.tfvars
        ├── main.tf
        ├── providers.tf
        ├── variables.tf
        └── versions.tf
```

>**NOTE**: The parent directory `examples/` includes all the **recipes**, being _default_ the "by default" recipe that represents the very basics of the module that's being developed.

## Run recipes directly
Use [Taskfile] for doing so. The `Taskfile.yml` file is located in the root of the repo, and it's used for running the recipes. The [Taskfile] tasks that are related to these recipes are customizable by the following input variables:
* `MODULE`: The module's name. Default: `default` — it should match the module's name defined beneath the directory `examples/`. E.g.: `examples/<MODULE>/...`
* `RECIPE`: The recipe's name. Default: `basic` — it should match the recipe's name defined beneath the directory `examples/<MODULE>/...`. E.g.: `examples/<MODULE>/<RECIPE>/...`

```bash
task recipe-init
```

```bash
task recipe-ci
```

```bash
task recipe-plan
```


<!-- References -->

<!-- markdown-link-check-disable -->
[terratest]: https://github.com/gruntwork-io/terratest
[Taskfile]: https://taskfile.dev/#/

<!-- markdown-link-check-enable -->
