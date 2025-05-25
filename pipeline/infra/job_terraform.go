package main

import (
	"context"
	"dagger/infra/internal/dagger"
	"sync"
)

// JobTerraform performs a command on Terraform by:
func (m *Infra) JobTerraform(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
	// tfModulePath is the path to the Terraform modules.
	// +optional
	tfModulePath string,
	// awsAccessKeyID is the AWS access key ID.
	// +optional
	awsAccessKeyID *dagger.Secret,
	// awsSecretAccessKey is the AWS secret access key.
	// +optional
	awsSecretAccessKey *dagger.Secret,
	// awsSessionToken is the AWS session token.
	// +optional
	awsSessionToken *dagger.Secret,
	// awsRegion is the AWS region to use for the remote backend.
	// +optional
	awsRegion string,
	// tfRegistryGitlabToken is the Terraform Gitlab token.
	// +optional
	tfRegistryGitlabToken *dagger.Secret,
	// GitHubToken is the github token
	// +optional
	gitHubToken *dagger.Secret,
	// GitlabToken is the Gitlab token.
	// +optional
	gitlabToken *dagger.Secret,
	// loadDotEnvFile is a flag to enable source .env files from the local directory.
	// +optional
	loadDotEnvFile bool,
	// NoCache is a flag to disable caching of the container.
	// +optional
	noCache bool,
	// envVars are the environment variables to set in the container.
	// +optional
	envVars []string,
	// gitSSH is a flag to enable SSH for the container.
	// +optional
	gitSSH *dagger.Socket,
	// logLevel is the Terraform log level to use.
	// +optional
	logLevel string,
	// dotTerraformVersion is the Terraform version to generate a .terraform-version file in the working directory.
	// +optional
	dotTerraformVersion string,
) (*dagger.Container, error) {
	if tfModulePath != "" {
		tfExecutionPath := getTerraformModulesExecutionPath(tfModulePath)
		m.Ctr = m.
			Ctr.
			WithWorkdir(tfExecutionPath)
	}

	if len(envVars) > 0 {
		mWithEnvVars, err := m.WithEnvVars(envVars)
		if err != nil {
			return nil, WrapErrorf(err, "failed to set environment variables")
		}

		m = mWithEnvVars
	}

	if gitSSH != nil {
		m = m.WithSSHAuthSocket(gitSSH, "", "", false, true)
	}

	if loadDotEnvFile {
		mDecorated, err := m.WithDotEnvFile(ctx, m.Src)
		if err != nil {
			return nil, WrapErrorf(err, "failed to source .env files from the local directory")
		}

		m = mDecorated
	}

	if noCache {
		m = m.WithCacheBuster()
	}

	if awsAccessKeyID != nil && awsSecretAccessKey != nil {
		m = m.WithAWSKeys(ctx, awsAccessKeyID, awsSecretAccessKey, awsRegion, awsSessionToken)
	}

	if tfRegistryGitlabToken != nil {
		m = m.WithTerraformRegistryGitlabToken(ctx, tfRegistryGitlabToken)
	}

	if gitlabToken != nil {
		m = m.WithGitlabToken(ctx, gitlabToken)
	}

	if gitHubToken != nil {
		m = m.WithGitHubToken(ctx, gitHubToken)
	}

	if logLevel != "" {
		m = m.WithTerraformLogLevel(logLevel)
	}

	if dotTerraformVersion != "" {
		m = m.WithDotTerraformVersionFileGeneration(dotTerraformVersion)
	}

	return m.Ctr, nil
}

// JobTerraformExec executes a Terraform command with arguments using a pre-configured container.
// This function reuses JobTerraform to create the base container and then executes the specified
// terraform command with the provided arguments.
func (m *Infra) JobTerraformExec(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
	// command is the Terraform command to execute (e.g., "plan", "apply", "destroy")
	command string,
	// tfModulePath is the path to the Terraform modules.
	tfModulePath string,
	// arguments are the optional arguments to pass to the Terraform command
	// +optional
	arguments []string,
	// awsAccessKeyID is the AWS access key ID.
	// +optional
	awsAccessKeyID *dagger.Secret,
	// awsSecretAccessKey is the AWS secret access key.
	// +optional
	awsSecretAccessKey *dagger.Secret,
	// awsSessionToken is the AWS session token.
	// +optional
	awsSessionToken *dagger.Secret,
	// awsRegion is the AWS region to use for the remote backend.
	// +optional
	awsRegion string,
	// tfRegistryGitlabToken is the Terraform Gitlab token.
	// +optional
	tfRegistryGitlabToken *dagger.Secret,
	// GitHubToken is the github token
	// +optional
	gitHubToken *dagger.Secret,
	// GitlabToken is the Gitlab token.
	// +optional
	gitlabToken *dagger.Secret,
	// loadDotEnvFile is a flag to enable source .env files from the local directory.
	// +optional
	loadDotEnvFile bool,
	// NoCache is a flag to disable caching of the container.
	// +optional
	noCache bool,
	// envVars are the environment variables to set in the container.
	// +optional
	envVars []string,
	// gitSSH is a flag to enable SSH for the container.
	// +optional
	gitSSH *dagger.Socket,
	// logLevel is the Terraform log level to use.
	// +optional
	logLevel string,
	// dotTerraformVersion is the Terraform version to generate a .terraform-version file in the working directory.
	// +optional
	dotTerraformVersion string,
) (string, error) {
	// Get the base container using JobTerraform
	container, err := m.JobTerraform(
		ctx,
		tfModulePath,
		awsAccessKeyID,
		awsSecretAccessKey,
		awsSessionToken,
		awsRegion,
		tfRegistryGitlabToken,
		gitHubToken,
		gitlabToken,
		loadDotEnvFile,
		noCache,
		envVars,
		gitSSH,
		logLevel,
		dotTerraformVersion,
	)

	if err != nil {
		return "", WrapErrorf(err, "failed to create base Terraform container")
	}

	// Build the terraform command with arguments
	terraformCmd, err := buildTerraformCommand(command, arguments)
	if err != nil {
		return "", WrapErrorf(err, "failed to build Terraform command")
	}

	// Execute the terraform command
	container = container.
		WithExec(terraformCmd)

	// Get the output of the container
	output, err := container.Stdout(ctx)

	if err != nil {
		return "", WrapErrorf(err, "failed to get output from Terraform container")
	}

	return output, nil
}

// JobTerraformStaticCheck performs static analysis checks on Terraform code.
// It runs three concurrent checks: init, validate, and format checking.
// This function reuses JobTerraform to create the base container and then executes
// the static analysis commands concurrently for better performance.
func (m *Infra) JobTerraformStaticCheck(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
	// tfModulePath is the path to the Terraform modules.
	tfModulePath string,
	// awsAccessKeyID is the AWS access key ID.
	// +optional
	awsAccessKeyID *dagger.Secret,
	// awsSecretAccessKey is the AWS secret access key.
	// +optional
	awsSecretAccessKey *dagger.Secret,
	// awsSessionToken is the AWS session token.
	// +optional
	awsSessionToken *dagger.Secret,
	// awsRegion is the AWS region to use for the remote backend.
	// +optional
	awsRegion string,
	// tfRegistryGitlabToken is the Terraform Gitlab token.
	// +optional
	tfRegistryGitlabToken *dagger.Secret,
	// GitHubToken is the github token
	// +optional
	gitHubToken *dagger.Secret,
	// GitlabToken is the Gitlab token.
	// +optional
	gitlabToken *dagger.Secret,
	// loadDotEnvFile is a flag to enable source .env files from the local directory.
	// +optional
	loadDotEnvFile bool,
	// NoCache is a flag to disable caching of the container.
	// +optional
	noCache bool,
	// envVars are the environment variables to set in the container.
	// +optional
	envVars []string,
	// gitSSH is a flag to enable SSH for the container.
	// +optional
	gitSSH *dagger.Socket,
	// logLevel is the Terraform log level to use.
	// +optional
	logLevel string,
	// dotTerraformVersion is the Terraform version to generate a .terraform-version file in the working directory.
	// +optional
	dotTerraformVersion string,
) (string, error) {
	// Get the base container using JobTerraform
	baseContainer, err := m.JobTerraform(
		ctx,
		tfModulePath,
		awsAccessKeyID,
		awsSecretAccessKey,
		awsSessionToken,
		awsRegion,
		tfRegistryGitlabToken,
		gitHubToken,
		gitlabToken,
		loadDotEnvFile,
		noCache,
		envVars,
		gitSSH,
		logLevel,
		dotTerraformVersion,
	)
	if err != nil {
		return "", WrapErrorf(err, "failed to create base Terraform container")
	}

	// Create channel for collecting results from concurrent operations
	resultChan := make(chan JobResult, 3)

	// Define the static check commands
	staticChecks := []struct {
		name     string
		commands [][]string
	}{
		{
			name: "init",
			commands: [][]string{
				{"terraform", "init", "-backend=false"},
			},
		},
		{
			name: "validate",
			commands: [][]string{
				{"terraform", "init", "-backend=false"},
				{"terraform", "validate"},
			},
		},
		{
			name: "fmt-check",
			commands: [][]string{
				{"terraform", "fmt", "-check", "-diff"},
			},
		},
	}

	// Use WaitGroup to wait for all goroutines to complete
	var wg sync.WaitGroup
	wg.Add(len(staticChecks))

	// Execute static checks concurrently
	for _, check := range staticChecks {
		go func(checkName string, checkCommands [][]string) {
			defer wg.Done()
			executeDaggerCtrAsync(
				ctx,
				resultChan,
				baseContainer,
				checkName,
				checkCommands,
			)
		}(check.name, check.commands)
	}

	// Close the channel after all goroutines complete
	go func() {
		wg.Wait()
		close(resultChan)
	}()

	// Process the results from concurrent execution
	output, err := processActionAsyncResults(resultChan)
	if err != nil {
		return "", WrapErrorf(err, "static analysis checks failed")
	}

	return output, nil
}

// JobTerraformVersionCompatibilityCheck performs compatibility checks across multiple Terraform versions.
// It tests the Terraform modules against different versions to ensure compatibility.
// This function creates separate containers for each version and runs validation concurrently.
func (m *Infra) JobTerraformVersionCompatibilityCheck(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
	// tfModulePath is the path to the Terraform modules.
	tfModulePath string,
	// awsAccessKeyID is the AWS access key ID.
	// +optional
	awsAccessKeyID *dagger.Secret,
	// awsSecretAccessKey is the AWS secret access key.
	// +optional
	awsSecretAccessKey *dagger.Secret,
	// awsSessionToken is the AWS session token.
	// +optional
	awsSessionToken *dagger.Secret,
	// awsRegion is the AWS region to use for the remote backend.
	// +optional
	awsRegion string,
	// tfRegistryGitlabToken is the Terraform Gitlab token.
	// +optional
	tfRegistryGitlabToken *dagger.Secret,
	// GitHubToken is the github token
	// +optional
	gitHubToken *dagger.Secret,
	// GitlabToken is the Gitlab token.
	// +optional
	gitlabToken *dagger.Secret,
	// loadDotEnvFile is a flag to enable source .env files from the local directory.
	// +optional
	loadDotEnvFile bool,
	// NoCache is a flag to disable caching of the container.
	// +optional
	noCache bool,
	// envVars are the environment variables to set in the container.
	// +optional
	envVars []string,
	// gitSSH is a flag to enable SSH for the container.
	// +optional
	gitSSH *dagger.Socket,
	// logLevel is the Terraform log level to use.
	// +optional
	logLevel string,
	// dotTerraformVersion is the Terraform version to generate a .terraform-version file in the working directory.
	// +optional
	dotTerraformVersion string,
) (string, error) {
	// Define Terraform versions to test against
	versions := []string{
		"1.11.1",
		"1.11.2",
		"1.11.3",
		"1.11.4",
	}

	// Create channel for collecting results from concurrent version tests
	// Buffer size = versions * checks per version
	resultChan := make(chan JobResult, len(versions)*2)

	// Use WaitGroup to wait for all version tests to complete
	var wg sync.WaitGroup
	wg.Add(len(versions) * 2) // 2 checks per version (init + validate)

	// Test each Terraform version concurrently
	for _, version := range versions {
		go func(tfVersion string) {
			// Create a copy of the Infra instance for this version
			versionedInfra := &Infra{
				Ctr: m.Ctr,
				Src: m.Src,
			}

			// Install the specific Terraform version
			versionedInfra = versionedInfra.WithTerraform(tfVersion)

			// Get the base container for this version
			baseContainer, err := versionedInfra.JobTerraform(
				ctx,
				tfModulePath,
				awsAccessKeyID,
				awsSecretAccessKey,
				awsSessionToken,
				awsRegion,
				tfRegistryGitlabToken,
				gitHubToken,
				gitlabToken,
				loadDotEnvFile,
				noCache,
				envVars,
				gitSSH,
				logLevel,
				dotTerraformVersion,
			)

			if err != nil {
				// Send error result for this version
				defer wg.Done()
				defer wg.Done() // Decrement twice since we're skipping both checks
				resultChan <- JobResult{
					WorkDir: tfVersion + ".init",
					Output:  "",
					Err:     WrapErrorf(err, "failed to create container for Terraform version %s", tfVersion),
				}
				return
			}

			// Define compatibility checks for this version
			versionChecks := []struct {
				name     string
				commands [][]string
			}{
				{
					name: tfVersion + ".init",
					commands: [][]string{
						{"terraform", "version"},
						{"terraform", "init", "-backend=false"},
					},
				},
				{
					name: tfVersion + ".validate",
					commands: [][]string{
						{"terraform", "version"},
						{"terraform", "init", "-backend=false"},
						{"terraform", "validate"},
					},
				},
			}

			// Execute checks for this version
			for _, check := range versionChecks {
				go func(checkName string, checkCommands [][]string, container *dagger.Container) {
					defer wg.Done()
					executeDaggerCtrAsync(
						ctx,
						resultChan,
						container,
						checkName,
						checkCommands,
					)
				}(check.name, check.commands, baseContainer)
			}
		}(version)
	}

	// Close the channel after all goroutines complete
	go func() {
		wg.Wait()
		close(resultChan)
	}()

	// Process the results from concurrent execution
	output, err := processActionAsyncResults(resultChan)
	if err != nil {
		return "", WrapErrorf(err, "version compatibility checks failed")
	}

	return output, nil
}
