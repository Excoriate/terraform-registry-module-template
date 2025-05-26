package main

import (
	"context"
	"dagger/infra/internal/dagger"
	"path/filepath"
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

// ActionTerraformVersionCompatibilityVerification performs compatibility checks across multiple Terraform versions.
// It tests the Terraform modules against different versions to ensure compatibility.
// This function creates separate containers for each version and runs validation sequentially.
func (m *Infra) ActionTerraformVersionCompatibilityVerification(
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
	// tfVersionsToVerify is the list of Terraform versions to verify.
	// +optional
	tfVersionsToVerify []string,
) (*dagger.Container, error) {
	// Define Terraform versions to test against
	versions := []string{
		"1.12.0",
		"1.12.1",
	}

	if len(tfVersionsToVerify) > 0 {
		versions = append(versions, tfVersionsToVerify...)
	}

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

	// Test each Terraform version sequentially
	for _, version := range versions {
		// Install the specific Terraform version
		versionContainer := baseContainer.WithExec([]string{"sh", "-c", getTFInstallCmd(version)})

		// Define compatibility check commands for this version
		versionCMDs := []DaggerCMD{
			{"terraform", "version"},
			{"terraform", "init", "-backend=false"},
			{"terraform", "validate"},
		}

		// Execute compatibility checks using the reusable function
		versionContainer = addDaggerCMDs(versionContainer, versionCMDs...)

		// Update base container for next iteration
		baseContainer = versionContainer
	}

	return baseContainer, nil
}

func (m *Infra) ActionTerraformFileVerification(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
	// tfModulePath is the path to the Terraform modules.
	tfModulePath string,
	// files is the list of files to verify.
	// +optional
	files []string,
	// loadDotEnvFile is a flag to enable source .env files from the local directory.
	// +optional
	loadDotEnvFile bool,
	// NoCache is a flag to disable caching of the container.
	// +optional
	noCache bool,
	// envVars are the environment variables to set in the container.
) (*dagger.Container, error) {
	mandatoryTFModuleFiles := []string{
		"main.tf",
		"variables.tf",
		"outputs.tf",
		"locals.tf",
		"versions.tf",
	}

	mandatoryTFDocFiles := []string{
		"README.md",
		".terraform-docs.yml",
	}

	mandatoryTFToolingFiles := []string{
		".tflint.hcl",
	}

	// Get the base container using JobTerraform
	baseContainer, err := m.JobTerraform(
		ctx,
		tfModulePath,
		nil,
		nil,
		nil,
		"",
		nil,
		nil,
		nil,
		loadDotEnvFile,
		noCache,
		nil,
		nil,
		"",
		"",
		"",
		"",
	)

	if err != nil {
		return nil, WrapErrorf(err, "failed to create base Terraform container")
	}

	tfModuleDirectory := m.Src.Directory("modules/" + tfModulePath)

	tfModuleEntries, tfModuleEntriesErr := tfModuleDirectory.
		Entries(ctx)

	if tfModuleEntriesErr != nil {
		return nil, WrapErrorf(tfModuleEntriesErr, "failed to get Terraform module entries")
	}

	// Create a map of found files for efficient lookup
	foundFiles := make(map[string]bool)
	for _, entry := range tfModuleEntries {
		foundFiles[entry] = true
	}

	// Validate each file category with specific error messages
	var missingTFModuleFiles []string
	var missingDocFiles []string
	var missingToolingFiles []string
	var missingAdditionalFiles []string

	// Check Terraform module files
	for _, file := range mandatoryTFModuleFiles {
		if !foundFiles[file] {
			missingTFModuleFiles = append(missingTFModuleFiles, file)
		}
	}

	// Check documentation files
	for _, file := range mandatoryTFDocFiles {
		if !foundFiles[file] {
			missingDocFiles = append(missingDocFiles, file)
		}
	}

	// Check tooling files
	for _, file := range mandatoryTFToolingFiles {
		if !foundFiles[file] {
			missingToolingFiles = append(missingToolingFiles, file)
		}
	}

	// Check additional files if provided
	for _, file := range files {
		if !foundFiles[file] {
			missingAdditionalFiles = append(missingAdditionalFiles, file)
		}
	}

	// Report missing files with category-specific error messages including mandatory file lists
	if len(missingTFModuleFiles) > 0 {
		return nil, Errorf("mandatory Terraform module files are missing: %v (required: %v)", missingTFModuleFiles, mandatoryTFModuleFiles)
	}

	if len(missingDocFiles) > 0 {
		return nil, Errorf("mandatory documentation files are missing: %v (required: %v)", missingDocFiles, mandatoryTFDocFiles)
	}

	if len(missingToolingFiles) > 0 {
		return nil, Errorf("mandatory tooling files are missing: %v (required: %v)", missingToolingFiles, mandatoryTFToolingFiles)
	}

	if len(missingAdditionalFiles) > 0 {
		return nil, Errorf("additional required files are missing: %v (specified: %v)", missingAdditionalFiles, files)
	}

	return baseContainer, nil
}

func (m *Infra) ActionTerraformBuild(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
	// tfModulePath is the path to the Terraform modules.
	tfModulePath string,
	// fixture is the fixture to use for the build, meaning, the file.tfvars file to use.
	// +optional
	fixture string,
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
		"",
		"",
		"",
	)

	if err != nil {
		return nil, WrapErrorf(err, "failed to create base Terraform container")
	}

	buildTFCommands := []DaggerCMD{
		{"terraform", "init", "-backend=false"},
	}

	if fixture != "" {
		fixturePath := filepath.Join(configTerraformFixturesPath, fixture)
		buildTFCommands = append(buildTFCommands, DaggerCMD{"terraform", "plan", "-var-file=" + fixturePath})
	} else {
		buildTFCommands = append(buildTFCommands, DaggerCMD{"terraform", "plan"})
	}

	baseContainer = addDaggerCMDs(baseContainer, buildTFCommands...)

	return baseContainer, nil
}

func (m *Infra) ActionTerraformDocs(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
	// tfModulePath is the path to the Terraform modules.
	tfModulePath string,
	// loadDotEnvFile is a flag to enable source .env files from the local directory.
	// +optional
	loadDotEnvFile bool,
	// NoCache is a flag to disable caching of the container.
	// +optional
	noCache bool,
	// terraformDocsVersion is the terraform-docs version to use.
	// +optional
	terraformDocsVersion string,
) (*dagger.Container, error) {
	tfDocsConfigFile := ".terraform-docs.yml"

	tfDocCommands := []DaggerCMD{
		{"cat", tfDocsConfigFile},
		{"terraform-docs", "markdown", ".", "--output-file", "README.md"},
	}

	m = m.WithTerraformDocs(terraformDocsVersion)

	// Get the base container using JobTerraform
	baseContainer, err := m.JobTerraform(
		ctx,
		tfModulePath,
		nil,
		nil,
		nil,
		"",
		nil,
		nil,
		nil,
		loadDotEnvFile,
		noCache,
		nil,
		nil,
		"",
		"",
		"",
		"",
		// FIXME: This is not working as expected, the terraform-docs version is not being set.
		// terraformDocsVersion,
	)

	if err != nil {
		return nil, WrapErrorf(err, "failed to create base Terraform container")
	}

	baseContainer = addDaggerCMDs(baseContainer, tfDocCommands...)

	return baseContainer, nil
}

func (m *Infra) ActionTerraformLint(
	// Context is the context for managing the operation's lifecycle
	// +optional
	ctx context.Context,
	// tfModulePath is the path to the Terraform modules.
	tfModulePath string,
	// loadDotEnvFile is a flag to enable source .env files from the local directory.
	// +optional
	loadDotEnvFile bool,
	// NoCache is a flag to disable caching of the container.
	// +optional
	noCache bool,
	// tflintVersion is the TFLint version to use.
	// +optional
	tflintVersion string,
) (*dagger.Container, error) {
	tfLintConfigFile := ".tflint.hcl"

	tfLintCommands := []DaggerCMD{
		{"cat", tfLintConfigFile},
		{"tflint", "--init"},
		{"tflint", "--recursive"},
	}

	m = m.WithTFLint(tflintVersion)

	// Get the base container using JobTerraform
	baseContainer, err := m.JobTerraform(
		ctx,
		tfModulePath,
		nil,
		nil,
		nil,
		"",
		nil,
		nil,
		nil,
		loadDotEnvFile,
		noCache,
		nil,
		nil,
		"",
		"",
		"",
		"",
	)

	if err != nil {
		return nil, WrapErrorf(err, "failed to create base Terraform container")
	}

	baseContainer = addDaggerCMDs(baseContainer, tfLintCommands...)

	return baseContainer, nil
}
