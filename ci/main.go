package main

import (
	"context"
	"dagger/terraformci/internal/dagger"
	"fmt"
	"path/filepath"
	"strings"
	"time"
)

const (
	defaultTFVersion   = "1.11.2"
	defaultImageURL    = "alpine:3.18"
	defaultMntPath     = "/src"
	tfFileExtension    = ".tf"
	defaultExampleName = "basic"
	defaultModuleName  = "default"
)

// Terraformci represents a configurable Terraform CI container with various configuration options.
// It provides methods to set up a container environment for Terraform-related operations.
type Terraformci struct {
	// Ctr is the container to use as a base container.
	Ctr *dagger.Container
	// Src is the source directory to use for the Terraform CI container.
	Src *dagger.Directory
}

// New creates and configures a new Terraformci instance with flexible initialization options.
//
// The function supports multiple ways of creating a container:
// 1. Using a provided container
// 2. Using a custom image URL
// 3. Using a default Alpine image with specified Terraform version
//
// Parameters:
//   - ctx: Optional context for container operations
//   - ctr: Optional base container to use (takes precedence if provided)
//   - imageURL: Optional custom image URL with tag (e.g., "ghcr.io/devops-infra/docker-terragrunt:tf-1.9.5")
//   - tfVersion: Optional Terraform version to install (defaults to "1.11.2")
//   - secrets: Optional list of secrets to mount in the container
//   - envVars: Optional list of environment variables to set
//   - srcDir: Optional source directory to mount in the container
//
// Returns:
//   - A configured Terraformci instance
//   - An error if container initialization fails
func New(
	// ctx is the context to use for the container.
	// +optional
	ctx context.Context,
	// ctr is the container to use as a base container.
	// +optional
	ctr *dagger.Container,
	// imageURL is the URL of the image to use as the base container.
	// It should includes tags. E.g. "ghcr.io/devops-infra/docker-terragrunt:tf-1.9.5-ot-1.8.2-tg-0.67.4"
	// +optional
	imageURL string,
	// tgVersion is the Terragrunt version to use. Default is "0.68.1".
	// +optional
	tfVersion string,
	// tfVersion is the Terraform version to use. Default is "1.9.1".
	// +optional
	secrets []*dagger.Secret,
	// envVars is a map of environment variables to set in the container.
	// +optional
	envVars []string,
	// srcDir is the directory to mount as the source code.
	// +optional
	// +defaultPath="/"
	// +ignore=["*", "!**/*.hcl", "!**/*.tfvars", "!**/*.tfvars.json", "!**/*.tf"]
	srcDir *dagger.Directory,
	// tfPath is the path to the Terraform source code.
	// +optional
	tfPath string,
) (*Terraformci, error) {
	if ctr != nil {
		mod := &Terraformci{Ctr: ctr}
		mod.WithSecrets(ctx, secrets)
		mod.WithSRC(ctx, tfPath, srcDir)
		mod, enVarError := mod.WithEnvVars(envVars)

		if enVarError != nil {
			return nil, enVarError
		}

		return mod.
			WithTFPluginCache(), nil
	}

	if imageURL != "" {
		mod := &Terraformci{}
		mod.Ctr = dag.Container().From(imageURL)
		mod.WithSecrets(ctx, secrets)
		mod.WithSRC(ctx, tfPath, srcDir)
		mod, enVarError := mod.WithEnvVars(envVars)

		if enVarError != nil {
			return nil, enVarError
		}

		return mod.
			WithTFPluginCache(), nil
	}

	// We'll use the binary that should be downloaded from its source, or github repository.
	mod := &Terraformci{}
	if tfVersion == "" {
		tfVersion = defaultTFVersion
	}

	mod.Ctr = dag.Container().From(defaultImageURL)
	mod.Ctr = mod.Ctr.WithExec([]string{"sh", "-c", getTFInstallCmd(tfVersion)})
	mod.Ctr = mod.Ctr.WithExec([]string{"terraform", "version"})

	mod.WithSecrets(ctx, secrets)
	mod.WithSRC(ctx, tfPath, srcDir)
	mod, enVarError := mod.WithEnvVars(envVars)

	if enVarError != nil {
		return nil, enVarError
	}

	return mod.
		WithTFPluginCache(), nil
}

func (t *Terraformci) WithTFPluginCache() *Terraformci {
	t.Ctr = t.Ctr.
		WithExec([]string{"mkdir", "-p", "/root/.terraform.d/plugin-cache"}).
		WithExec([]string{"chmod", "755", "/root/.terraform.d/plugin-cache"}).
		WithMountedCache("/root/.terraform.d/plugin-cache", dag.CacheVolume("terraform-plugin-cache"))

	return t
}

func getTFInstallCmd(tfVersion string) string {
	installDir := "/usr/local/bin/terraform"
	command := fmt.Sprintf(`apk add --no-cache curl unzip &&
	curl -L https://releases.hashicorp.com/terraform/%[1]s/terraform_%[1]s_linux_amd64.zip -o /tmp/terraform.zip &&
	unzip /tmp/terraform.zip -d /tmp &&
	mv /tmp/terraform %[2]s &&
	chmod +x %[2]s &&
	rm /tmp/terraform.zip`, tfVersion, installDir)

	return strings.TrimSpace(command)
}

func isNonEmptyDaggerDir(ctx context.Context, dir *dagger.Directory) error {
	if dir == nil {
		return fmt.Errorf("dagger directory cannot be nil")
	}

	entries, err := dir.Entries(ctx)
	if err != nil {
		return fmt.Errorf("failed to get entries from the dagger directory passed: %w", err)
	}

	if len(entries) == 0 {
		return fmt.Errorf("no entries found in the dagger directory passed")
	}

	return nil
}

// WithSecrets adds secrets to the Terraformci container, making them available as environment variables.
//
// This method allows secure injection of sensitive information into the container.
//
// Parameters:
//   - secrets: A slice of Dagger secrets to be mounted in the container
//
// Returns:
//   - The updated Terraformci instance with secrets mounted
func (t *Terraformci) WithSecrets(ctx context.Context, secrets []*dagger.Secret) *Terraformci {
	for _, secret := range secrets {
		secretName, _ := secret.Name(ctx)
		t.Ctr = t.Ctr.WithSecretVariable(secretName, secret)
	}

	return t
}

// WithSRC mounts a source directory into the Terraformci container.
//
// This method sets the working directory and mounts the provided directory,
// preparing the container for source code operations.
//
// Parameters:
//   - dir: A Dagger directory to be mounted in the container
//
// Returns:
//   - The updated Terraformci instance with source directory mounted
func (t *Terraformci) WithSRC(ctx context.Context, workdir string, dir *dagger.Directory) (*Terraformci, error) {
	if workdir != "" {
		workdir = filepath.Join(defaultMntPath, workdir)
	}

	if err := isNonEmptyDaggerDir(ctx, dir); err != nil {
		return t, fmt.Errorf("failed to validate the src/ directory passed: %w", err)
	}

	// TODO: More specialised validations can be added later.

	t.Ctr = t.Ctr.
		WithWorkdir(workdir).
		WithMountedDirectory(workdir, dir)

	t.Src = dir

	return t, nil
}

// WithEnvVars adds environment variables to the Terraformci container.
//
// This method allows setting multiple environment variables in key=value format.
// It performs validation to ensure each environment variable is correctly formatted.
//
// Parameters:
//   - envVars: A slice of environment variables in "KEY=VALUE" format
//
// Returns:
//   - The updated Terraformci instance with environment variables set
//   - An error if any environment variable is incorrectly formatted
func (t *Terraformci) WithEnvVars(envVars []string) (*Terraformci, error) {
	if len(envVars) > 0 {
		for _, envVar := range envVars {
			trimmedEnvVar := strings.TrimSpace(envVar)
			if !strings.Contains(trimmedEnvVar, "=") {
				return nil, fmt.Errorf("environment variable must be in the format ENVARKEY=VALUE: %s", trimmedEnvVar)
			}

			parts := strings.Split(trimmedEnvVar, "=")
			if len(parts) != 2 {
				return nil, fmt.Errorf("environment variable must be in the format ENVARKEY=VALUE: %s", trimmedEnvVar)
			}

			t.Ctr = t.Ctr.WithEnvVariable(parts[0], parts[1])
		}
	}

	return t, nil
}

// OpenTerminal provides an interactive terminal for the Terraformci container.
//
// This method returns a container with an open terminal, useful for interactive debugging
// or manual command execution within the Terraform CI environment.
//
// Returns:
//   - A Dagger container with an open terminal
//
// Example:
//
//	terminal := terraformci.OpenTerminal()
//	terminal.Exec([]string{"terraform", "version"})
func (t *Terraformci) OpenTerminal() *dagger.Container {
	return t.Ctr.Terminal()
}

// TFStatic validates the module directory passed and returns a container for the module.
//
// This method performs the following checks:
// 1. Run Terraform init
// 2. Run Terraform validate
// 3. Run Terraform fmt -check
func (t *Terraformci) TFStatic(ctx context.Context,
	// tfSrc is the source directory to validate
	tfSrc *dagger.Directory,
	// tfPath is the path to the Terraform source code
	// +optional
	tfPath string,
	// cacheBurst is the flag to enable cache busting
	// +optional
	cacheBurst bool,
) (*dagger.Container, error) {
	if _, err := t.WithSRC(ctx, tfPath, tfSrc); err != nil {
		return nil, fmt.Errorf("failed to validate the module directory passed: %w", err)
	}

	if cacheBurst {
		t.Ctr = t.Ctr.
			WithEnvVariable("CACHE_BUSTER", time.
				Now().
				Format(time.RFC3339Nano))
	}

	t.Ctr = t.Ctr.
		WithExec([]string{"terraform", "init"}).
		WithExec([]string{"terraform", "validate"}).
		WithExec([]string{"terraform", "fmt", "-check"})

	return t.Ctr, nil
}

func (t *Terraformci) TFExamplesStatic(ctx context.Context,
	// moduleName is the name of the module to validate
	// +optional
	moduleName string,
	// exampleName is the name of the example to validate
	// +optional
	exampleName string,
	// tfExamples is the examples directory to validate
	// +optional
	cacheBurst bool,
) (*dagger.Container, error) {
	if cacheBurst {
		t.Ctr = t.Ctr.
			WithEnvVariable("CACHE_BUSTER", time.
				Now().
				Format(time.RFC3339Nano))
	}

	if exampleName == "" {
		exampleName = defaultExampleName
	}

	if moduleName == "" {
		moduleName = defaultModuleName
	}

	// moduleNameNormalised := filepath.Join("modules", moduleName)
	exampleNameNormalised := filepath.Join("examples", moduleName, exampleName)

	t.Ctr = t.Ctr.
		WithExec([]string{"sh", "-c", fmt.Sprintf("cd %s", exampleNameNormalised)}).
		WithExec([]string{"terraform", "init"}).
		WithExec([]string{"terraform", "validate"}).
		WithExec([]string{"terraform", "fmt", "-check"})

	return t.Ctr, nil
}

// TFStaticCI validates the module directory passed and returns the output of the terraform static check.
//
// This method performs the following checks:
// 1. Run Terraform init
// 2. Run Terraform validate
// 3. Run Terraform fmt -check
func (t *Terraformci) TFStaticCI(ctx context.Context,
	// tfModule is the module directory to validate
	tfModule *dagger.Directory,
	// tfPath is the path to the Terraform source code
	// +optional
	tfPath string,
	// cacheBurst is the flag to enable cache busting
	// +optional
	cacheBurst bool,
) (string, error) {
	container, err := t.TFStatic(ctx, tfModule, tfPath, cacheBurst)

	if err != nil {
		return "", fmt.Errorf("failed to validate the module directory passed: %w", err)
	}

	return container.Stdout(ctx)
}
