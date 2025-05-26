package main

import (
	"context"
	"dagger/infra/internal/dagger"
	"sync"
)

// JobTerraformStaticCheck performs static analysis checks on Terraform code.
// It runs three concurrent checks: init, validate, and format checking.
// This function reuses JobTerraform to create the base container and then executes
// the static analysis commands concurrently for better performance.
func (m *Infra) ActionTerraformStaticAnalysis(
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
	// tflintVersion is the TFLint version to use.
	// +optional
	tflintVersion string,
	// terraformDocsVersion is the terraform-docs version to use.
	// +optional
	terraformDocsVersion string,
) (*dagger.Container, error) {
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
		tflintVersion,
		terraformDocsVersion,
	)

	if err != nil {
		return nil, WrapErrorf(err, "failed to create base Terraform container")
	}

	// Define the static check commands using the DaggerCMD type
	actionCMDs := []DaggerCMD{
		{"terraform", "init", "-backend=false"},
		{"terraform", "validate"},
		{"terraform", "fmt", "-check", "-diff"},
	}

	// Execute static checks using the reusable function
	baseContainer = addDaggerCMDs(baseContainer, actionCMDs...)

	return baseContainer, nil
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
	// tflintVersion is the TFLint version to use.
	// +optional
	tflintVersion string,
	// terraformDocsVersion is the terraform-docs version to use.
	// +optional
	terraformDocsVersion string,
) (string, error) {
	// Define Terraform versions to test against
	versions := []string{
		"1.12.0",
		"1.12.1",
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
				tflintVersion,
				terraformDocsVersion,
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

// func (m *Infra) JobTerraformModuleCI(
// 	// Context is the context for managing the operation's lifecycle
// 	// +optional
// 	ctx context.Context,
// 	// tfModulePath is the path to the Terraform modules.
// 	tfModulePath string,
// 	// tfModuleExamplesPath is the path to the Terraform module examples.
// 	// +optional
// 	tfModuleExamplesPath []string,
// 	// awsAccessKeyID is the AWS access key ID.
// 	// +optional
// 	awsAccessKeyID *dagger.Secret,
// 	// awsSecretAccessKey is the AWS secret access key.
// 	// +optional
// 	awsSecretAccessKey *dagger.Secret,
// 	// awsSessionToken is the AWS session token.
// 	// +optional
// 	awsSessionToken *dagger.Secret,
// 	// awsRegion is the AWS region to use for the remote backend.
// 	// +optional
// 	awsRegion string,
// 	// tfRegistryGitlabToken is the Terraform Gitlab token.
// 	// +optional
// 	tfRegistryGitlabToken *dagger.Secret,
// 	// GitHubToken is the github token
// 	// +optional
// 	gitHubToken *dagger.Secret,
// 	// GitlabToken is the Gitlab token.
// 	// +optional
// 	gitlabToken *dagger.Secret,
// 	// loadDotEnvFile is a flag to enable source .env files from the local directory.
// 	// +optional
// 	loadDotEnvFile bool,
// 	// NoCache is a flag to disable caching of the container.
// 	// +optional
// 	noCache bool,
// 	// envVars are the environment variables to set in the container.
// 	// +optional
// 	envVars []string,
// 	// gitSSH is a flag to enable SSH for the container.
// 	// +optional
// 	gitSSH *dagger.Socket,
// 	// logLevel is the Terraform log level to use.
// 	// +optional
// 	logLevel string,
// 	// dotTerraformVersion is the Terraform version to generate a .terraform-version file in the working directory.
// 	// +optional
// 	dotTerraformVersion string,
// ) (string, error) {
// 	ctrs := []*dagger.Container{}

// 	// Get the base container for this version
// 	tfModuleCIContainer, tfModuleCIContainerErr := m.JobTerraform(
// 		ctx,
// 		tfModulePath, // Path of the module
// 		awsAccessKeyID,
// 		awsSecretAccessKey,
// 		awsSessionToken,
// 		awsRegion,
// 		tfRegistryGitlabToken,
// 		gitHubToken,
// 		gitlabToken,
// 		loadDotEnvFile,
// 		noCache,
// 		envVars,
// 		gitSSH,
// 		logLevel,
// 		dotTerraformVersion,
// 	)

// 	tfModuleCIContainer = tfModuleCIContainer.
// 		WithExec([]string{"terraform", "init", "-backend=false"}).
// 		WithExec([]string{"terraform", "validate"}).
// 		WithExec([]string{"terraform", "fmt", "-check", "-diff"})

// 	if tfModuleCIContainerErr != nil {
// 		return "", WrapErrorf(tfModuleCIContainerErr, "failed to create base Terraform container")
// 	}

// 	for _, examplePath := range tfModuleExamplesPath {
// 		examplePath := filepath.Join("examples", tfModulePath, examplePath)
// 		exampleCICtr, exampleCICtrErr := m.JobTerraform(
// 			ctx,
// 			examplePath,
// 			awsAccessKeyID,
// 			awsSecretAccessKey,
// 			awsSessionToken,
// 			awsRegion,
// 			tfRegistryGitlabToken,
// 			gitHubToken,
// 			gitlabToken,
// 			loadDotEnvFile,
// 			noCache,
// 			envVars,
// 			gitSSH,
// 			logLevel,
// 			dotTerraformVersion,
// 		)

// 		if exampleCICtrErr != nil {
// 			return "", WrapErrorf(exampleCICtrErr, "failed to create example Terraform container")
// 		}

// 		exampleCICtr = exampleCICtr.
// 			WithExec([]string{"terraform", "init", "-backend=false"}).
// 			WithExec([]string{"terraform", "validate"}).
// 			WithExec([]string{"terraform", "fmt", "-check", "-diff"}).
// 			WithExec([]string{"terraform", "plan"})

// 		ctrs = append(ctrs, exampleCICtr)
// 	}
// 	// TODO: Complete later.
// 	return "", nil
// }
