package main

import (
	"context"
	"dagger/infra/internal/dagger"
	"path/filepath"
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
	// tflintVersion is the TFLint version to use.
	// +optional
	tflintVersion string,
	// terraformDocsVersion is the terraform-docs version to use.
	// +optional
	terraformDocsVersion string,
) (*dagger.Container, error) {
	job := m

	if noCache {
		job = job.WithCacheBuster()
	}

	if awsAccessKeyID != nil && awsSecretAccessKey != nil {
		job = job.WithAWSKeys(ctx, awsAccessKeyID, awsSecretAccessKey, awsRegion, awsSessionToken)
	}

	if tfRegistryGitlabToken != nil {
		job = job.WithTerraformRegistryGitlabToken(ctx, tfRegistryGitlabToken)
	}

	if gitlabToken != nil {
		job = job.WithGitlabToken(ctx, gitlabToken)
	}

	if gitHubToken != nil {
		job = job.WithGitHubToken(ctx, gitHubToken)
	}

	if logLevel != "" {
		job = job.WithTerraformLogLevel(logLevel)
	}

	if dotTerraformVersion != "" {
		job = job.WithDotTerraformVersionFileGeneration(dotTerraformVersion)
	}

	if tflintVersion != "" {
		job = job.WithTFLint(tflintVersion)
	}

	if terraformDocsVersion != "" {
		job = job.WithTerraformDocs(terraformDocsVersion)
	}

	if tfModulePath != "" {
		tfExecutionPath := getTerraformModulesExecutionPath(tfModulePath)
		job.Ctr = job.
			Ctr.
			WithWorkdir(filepath.Join(defaultMntPath, tfExecutionPath))
	}

	if len(envVars) > 0 {
		mWithEnvVars, err := job.WithEnvVars(envVars)
		if err != nil {
			return nil, WrapErrorf(err, "failed to set environment variables")
		}

		job = mWithEnvVars
	}

	if gitSSH != nil {
		job = job.WithSSHAuthSocket(gitSSH, "", "", false, true)
	}

	if loadDotEnvFile {
		mDecorated, err := job.WithDotEnvFile(ctx, job.Src)
		if err != nil {
			return nil, WrapErrorf(err, "failed to source .env files from the local directory")
		}

		job = mDecorated
	}

	return job.Ctr, nil
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
	// tflintVersion is the TFLint version to use.
	// +optional
	tflintVersion string,
	// terraformDocsVersion is the terraform-docs version to use.
	// +optional
	terraformDocsVersion string,
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
		tflintVersion,
		terraformDocsVersion,
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
