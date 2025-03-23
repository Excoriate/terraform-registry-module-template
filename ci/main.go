package main

import (
	"context"
	"dagger/terraformci/internal/dagger"
	"fmt"
	"strings"
)

const (
	defaultTFVersion  = "1.11.2"
	defaultImageURL   = "alpine:3.18"
	defaultModuleName = "default"
)

// Terraformci represents a configurable Terraform CI container with various configuration options.
// It provides methods to set up a container environment for Terraform-related operations.
type Terraformci struct {
	// Ctr is the container to use as a base container.
	Ctr *dagger.Container
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
) (*Terraformci, error) {
	if ctr != nil {
		mod := &Terraformci{Ctr: ctr}
		mod.WithSecrets(ctx, secrets)
		mod.WithSRC(ctx, srcDir)
		mod, enVarError := mod.WithEnvVars(envVars)

		if enVarError != nil {
			return nil, enVarError
		}

		return mod, nil
	}

	if imageURL != "" {
		mod := &Terraformci{}
		mod.Ctr = dag.Container().From(imageURL)
		mod.WithSecrets(ctx, secrets)
		mod.WithSRC(ctx, srcDir)
		mod, enVarError := mod.WithEnvVars(envVars)

		if enVarError != nil {
			return nil, enVarError
		}

		return mod, nil
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
	mod.WithSRC(ctx, srcDir)
	mod, enVarError := mod.WithEnvVars(envVars)

	if enVarError != nil {
		return nil, enVarError
	}

	return mod, nil
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
	if len(secrets) > 0 {
		for _, secret := range secrets {
			secretName, _ := secret.Name(ctx)
			t.Ctr = t.Ctr.WithSecretVariable(secretName, secret)
		}
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
func (t *Terraformci) WithSRC(ctx context.Context, dir *dagger.Directory) (*Terraformci, error) {
	mntPath := "/src"

	entries, err := dir.Entries(ctx)
	if err != nil {
		return t, fmt.Errorf("failed to get entries from the src/ directory passed: %w", err)
	}

	if len(entries) == 0 {
		return t, fmt.Errorf("no entries found in the src directory passed")
	}

	// TODO: More specialised validations can be added later.

	t.Ctr = t.Ctr.
		WithWorkdir(mntPath).
		WithMountedDirectory(mntPath, dir)

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

func (t *Terraformci) ModuleCI(moduleName string) (*dagger.Container, error) {
	if moduleName == "" {
		moduleName = defaultModuleName // It's expected that all the modules will have at least a single module called 'default'
	}

	return nil, nil
}
