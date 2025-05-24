package main

import (
	"context"
	"dagger/infra/internal/dagger"
)

// JobTerraform performs a command on Terraform by:
func (m *Infra) JobTerraform(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
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
	GitHubToken *dagger.Secret,
	// GitlabToken is the Gitlab token.
	// +optional
	GitlabToken *dagger.Secret,
	// loadDotEnvFile is a flag to enable source .env files from the local directory.
	// +optional
	loadDotEnvFile bool,
	// NoCache is a flag to disable caching of the container.
	// +optional
	noCache bool,
	// envVars are the environment variables to set in the container.
	// +optional
	envVars []string,
	// tfVersionFile is the Terraform version file to use. I'll generate a .terraform-version file in the working directory.
	// +optional
	tfVersionFile string,
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

	if GitlabToken != nil {
		m = m.WithGitlabToken(ctx, GitlabToken)
	}

	if GitHubToken != nil {
		m = m.WithGitHubToken(ctx, GitHubToken)
	}

	if logLevel != "" {
		m = m.WithTerraformLogLevel(logLevel)
	}

	if dotTerraformVersion != "" {
		m = m.WithDotTerraformVersionFileGeneration(dotTerraformVersion)
	}

	return m.Ctr, nil
}
