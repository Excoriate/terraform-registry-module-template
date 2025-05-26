package main

import (
	"context"
	"dagger/infra/internal/dagger"
	"fmt"
	"path/filepath"
	"strings"
)

func getTFInstallCmd(tfVersion string) string {
	installDir := "/usr/local/bin/terraform"
	command := fmt.Sprintf(`apk add --no-cache curl unzip &&
	curl -L https://releases.hashicorp.com/terraform/%[1]s/terraform_%[1]s_linux_amd64.zip -o /tmp/terraform.zip &&
	unzip -o /tmp/terraform.zip -d /tmp &&
	mv /tmp/terraform %[2]s &&
	chmod +x %[2]s &&
	rm /tmp/terraform.zip`, tfVersion, installDir)

	return strings.TrimSpace(command)
}

// getTFLintInstallCmd generates the installation command for TFLint.
// If version is empty, it installs the latest version using the official script.
// If version is specified, it downloads the specific version binary.
func getTFLintInstallCmd(tflintVersion string) string {
	if tflintVersion == "" {
		// Use the official installation script for latest version
		command := `apk add --no-cache curl bash &&
		curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash`
		return strings.TrimSpace(command)
	}

	// Install specific version
	installDir := "/usr/local/bin/tflint"
	command := fmt.Sprintf(`apk add --no-cache curl &&
	curl -L https://github.com/terraform-linters/tflint/releases/download/v%[1]s/tflint_linux_amd64.zip -o /tmp/tflint.zip &&
	unzip -o /tmp/tflint.zip -d /tmp &&
	mv /tmp/tflint %[2]s &&
	chmod +x %[2]s &&
	rm /tmp/tflint.zip`, tflintVersion, installDir)

	return strings.TrimSpace(command)
}

// getTerraformDocsInstallCmd generates the installation command for terraform-docs.
// If version is empty, it uses the default version defined in constants.
func getTerraformDocsInstallCmd(terraformDocsVersion string) string {
	if terraformDocsVersion == "" {
		terraformDocsVersion = defaultTerraformDocsVersion
	}

	installDir := "/usr/local/bin/terraform-docs"
	command := fmt.Sprintf(`apk add --no-cache curl tar &&
	curl -Lo /tmp/terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v%[1]s/terraform-docs-v%[1]s-$(uname)-amd64.tar.gz &&
	tar -xzf /tmp/terraform-docs.tar.gz -C /tmp &&
	chmod +x /tmp/terraform-docs &&
	mv /tmp/terraform-docs %[2]s &&
	rm /tmp/terraform-docs.tar.gz`, terraformDocsVersion, installDir)

	return strings.TrimSpace(command)
}

func isTfModuleDir(ctx context.Context, dir *dagger.Directory, extraFilesToCheck []string) error {
	entries, err := dir.Entries(ctx)
	if err != nil {
		return fmt.Errorf("failed to get entries from the dagger directory passed: %w", err)
	}

	// Predefined set of files
	predefinedFiles := append([]string{"main.tf", "variables.tf", "outputs.tf"}, extraFilesToCheck...)

	tfFileFound := false
	for _, entry := range entries {
		_, err := dir.File(entry).Contents(ctx)
		if err != nil {
			return fmt.Errorf("failed to get contents from the dagger file passed: %w", err)
		}

		// validate if it's a valid Terraform extension and in predefined set of files
		if filepath.Ext(entry) == ".tf" && contains(predefinedFiles, entry) {
			tfFileFound = true
			break
		}
	}

	if !tfFileFound {
		return fmt.Errorf("no Terraform module found in the directory")
	}

	return nil
}

// contains checks if a string slice contains a specific string value.
//
// This utility function performs a linear search through the provided slice
// to determine if the target string exists as an element. The comparison
// is case-sensitive and uses exact string matching.
//
// Parameters:
//   - slice: The string slice to search through
//   - str: The target string to search for
//
// Returns:
//   - bool: true if the string is found in the slice, false otherwise
//
// Time Complexity: O(n) where n is the length of the slice
//
// Example Usage:
//
//	files := []string{"main.tf", "variables.tf", "outputs.tf"}
//	hasMain := contains(files, "main.tf")     // returns true
//	hasTest := contains(files, "test.tf")     // returns false
func contains(slice []string, str string) bool {
	for _, v := range slice {
		if v == str {
			return true
		}
	}
	return false
}

// isNonEmptyDaggerDir validates that a Dagger directory is not nil and contains at least one entry.
//
// This validation function ensures that directory operations can proceed safely by
// checking both the directory object validity and its content. It's commonly used
// as a precondition check before performing directory operations in Dagger workflows.
//
// Parameters:
//   - ctx: Context for managing the operation's lifecycle and potential cancellation
//   - dir: The Dagger directory to validate. Can be nil.
//
// Returns:
//   - error: nil if the directory is valid and non-empty, otherwise a descriptive error
//
// Validation Checks:
//  1. Directory object is not nil
//  2. Directory entries can be successfully retrieved
//  3. Directory contains at least one entry (file or subdirectory)
//
// Error Cases:
//   - "dagger directory cannot be nil": when dir parameter is nil
//   - "failed to get entries from the dagger directory passed": when directory access fails
//   - "no entries found in the dagger directory passed": when directory is empty
//
// Example Usage:
//
//	if err := isNonEmptyDaggerDir(ctx, sourceDir); err != nil {
//	  return fmt.Errorf("invalid source directory: %w", err)
//	}
//	// Proceed with directory operations...
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

// getDefaultAWSRegionIfNotSet returns a default AWS region if the provided region is empty.
//
// This utility function ensures that AWS operations always have a valid region configured
// by falling back to a predefined default when no region is explicitly provided.
// It's commonly used in AWS provider configurations and resource deployments.
//
// Parameters:
//   - awsRegion: The AWS region string to validate. Can be empty or whitespace.
//
// Returns:
//   - string: The provided region if non-empty, otherwise the default AWS region
//
// Behavior:
//   - Returns the input region if it's a non-empty string
//   - Returns the default region (defined in constants) if input is empty
//   - Does not validate if the region name is a valid AWS region identifier
//
// Example Usage:
//
//	region := getDefaultAWSRegionIfNotSet("")           // returns default region
//	region := getDefaultAWSRegionIfNotSet("us-east-1") // returns "us-east-1"
func getDefaultAWSRegionIfNotSet(awsRegion string) string {
	if awsRegion == "" {
		return defaultAWSRegion
	}

	return awsRegion
}

// getTerraformModulesExecutionPath constructs the full filesystem path for a Terraform module
// by joining the configured modules root path with the specified module name.
//
// This function provides a standardized way to resolve module paths within the project
// structure, ensuring consistent path handling across different operations and platforms.
//
// Parameters:
//   - moduleName: The name of the Terraform module (e.g., "vpc", "security-groups")
//
// Returns:
//   - string: The complete filesystem path to the specified module directory
//
// Path Construction:
//   - Uses the configured root path for Terraform modules (configTerraformModulesRootPath)
//   - Joins the root path with the module name using filepath.Join for cross-platform compatibility
//   - Handles path separators correctly on different operating systems
//
// Example Usage:
//
//	modulePath := getTerraformModulesExecutionPath("vpc")
//	// Returns: "/path/to/modules/vpc" (on Unix-like systems)
//	// Returns: "C:\path\to\modules\vpc" (on Windows)
func getTerraformModulesExecutionPath(moduleName string) string {
	return filepath.Join(configTerraformModulesRootPath, moduleName)
}

// EnvVarDagger represents an environment variable with its key-value pair
// for use in Dagger container configurations.
//
// This struct provides a structured way to handle environment variables
// when configuring Dagger containers, ensuring type safety and clear
// separation between variable names and their values.
type EnvVarDagger struct {
	Key   string // The environment variable name (e.g., "AWS_REGION")
	Value string // The environment variable value (e.g., "us-west-2")
}

// getEnvVarsDaggerFromSlice converts a slice of "KEY=VALUE" environment variable
// strings into a slice of EnvVarDagger structs for Dagger container configuration.
//
// This function parses environment variable strings in the standard format and
// validates their structure to ensure they can be properly applied to Dagger containers.
// It performs strict validation to prevent malformed environment variables from
// causing runtime issues.
//
// Parameters:
//   - envVars: A slice of strings in "KEY=VALUE" format representing environment variables
//
// Returns:
//   - []EnvVarDagger: A slice of structured environment variable objects
//   - error: An error if any environment variable string is malformed or invalid
//
// Validation Rules:
//   - Environment variable strings cannot be empty or whitespace-only
//   - Each string must contain exactly one '=' character
//   - The format must be exactly "KEY=VALUE" with no additional '=' characters
//   - Keys cannot be empty after trimming whitespace
//
// Example Usage:
//
//	envVars := []string{"AWS_REGION=us-west-2", "DEBUG=true", "PORT=8080"}
//	daggerVars, err := getEnvVarsDaggerFromSlice(envVars)
//	if err != nil {
//	  // Handle validation error
//	}
//
// Error Cases:
//   - Empty or whitespace-only strings: "environment variable cannot be empty"
//   - Missing '=' separator: "environment variable must be in the format ENVARKEY=VALUE"
//   - Multiple '=' characters: "environment variable must be in the format ENVARKEY=VALUE"
func getEnvVarsDaggerFromSlice(envVars []string) ([]EnvVarDagger, error) {
	envVarsDagger := []EnvVarDagger{}
	for _, envVar := range envVars {
		trimmedEnvVar := strings.TrimSpace(envVar)
		if trimmedEnvVar == "" {
			return nil, NewError("environment variable cannot be empty")
		}

		if !strings.Contains(trimmedEnvVar, "=") {
			return nil, NewError(fmt.Sprintf("environment variable must be in the format ENVARKEY=VALUE: %s", trimmedEnvVar))
		}

		parts := strings.Split(trimmedEnvVar, "=")
		if len(parts) != 2 {
			return nil, NewError(fmt.Sprintf("environment variable must be in the format ENVARKEY=VALUE: %s", trimmedEnvVar))
		}

		envVarsDagger = append(envVarsDagger, EnvVarDagger{
			Key:   parts[0],
			Value: parts[1],
		})
	}

	return envVarsDagger, nil
}

// parseDotEnvFiles processes .env files found by WithDotEnvFile.
// It handles basic .env syntax including comments (#), empty lines,
// KEY=VALUE pairs, whitespace trimming, and basic quote removal (' or ").
func parseDotEnvFiles(ctx context.Context, container *dagger.Container, src *dagger.Directory, envFiles []string) (*dagger.Container, error) {
	for _, file := range envFiles {
		fileContent, err := src.File(file).Contents(ctx)
		if err != nil {
			// Wrap error for better context
			return nil, fmt.Errorf("failed to read dot env file '%s': %w", file, err)
		}

		lines := strings.Split(fileContent, "\n")

		for lineNum, line := range lines {
			trimmedLine := strings.TrimSpace(line)

			// Skip empty lines and comments
			if trimmedLine == "" || strings.HasPrefix(trimmedLine, "#") {
				continue
			}

			// Split line into key/value pair by the first '='
			parts := strings.SplitN(trimmedLine, "=", 2)
			if len(parts) != 2 {
				// Return error for lines without '='
				return nil, fmt.Errorf("invalid format in file '%s' on line %d: '%s'", file, lineNum+1, trimmedLine)
			}

			key := strings.TrimSpace(parts[0])
			value := strings.TrimSpace(parts[1])

			// Check for empty key
			if key == "" {
				return nil, fmt.Errorf("empty key found in file '%s' on line %d: '%s'", file, lineNum+1, trimmedLine)
			}

			// Trim surrounding quotes (basic handling)
			if len(value) >= 2 {
				if (value[0] == '"' && value[len(value)-1] == '"') || (value[0] == '\'' && value[len(value)-1] == '\'') {
					value = value[1 : len(value)-1]
				}
			}

			// Determine if it's a secret based on filename
			isSecret := strings.Contains(file, "secret")

			if isSecret {
				// Use a distinct name for the Dagger secret object itself
				secretName := fmt.Sprintf("%s_secret_%s", key, file)
				container = container.WithSecretVariable(key, dag.SetSecret(secretName, value))
			} else {
				container = container.WithEnvVariable(key, value)
			}
		}
	}

	return container, nil
}

// parseVariablesFromSlice converts a slice of "KEY=VALUE" strings into a map[string]string.
// This utility is used to work around Dagger's limitation with map arguments.
//
// Parameters:
//   - variables: A slice of strings in "KEY=VALUE" format
//
// Returns:
//   - map[string]string: A map with parsed key-value pairs
//   - error: An error if any variable string is malformed
func parseVariablesFromSlice(variables []string) (map[string]string, error) {
	result := make(map[string]string)

	for _, variable := range variables {
		trimmedVar := strings.TrimSpace(variable)
		if trimmedVar == "" {
			continue // Skip empty strings
		}

		if !strings.Contains(trimmedVar, "=") {
			return nil, NewError(fmt.Sprintf("variable must be in the format KEY=VALUE: %s", trimmedVar))
		}

		parts := strings.SplitN(trimmedVar, "=", 2)
		if len(parts) != 2 {
			return nil, NewError(fmt.Sprintf("variable must be in the format KEY=VALUE: %s", trimmedVar))
		}

		key := strings.TrimSpace(parts[0])
		value := strings.TrimSpace(parts[1])

		if key == "" {
			return nil, NewError(fmt.Sprintf("variable key cannot be empty: %s", trimmedVar))
		}

		result[key] = value
	}

	return result, nil
}

// parseCommandArgsFromString converts a comma-separated string of command arguments into a slice.
// This utility helps parse command-line arguments for Terraform commands.
//
// Parameters:
//   - argsString: A comma-separated string of arguments (e.g., "-auto-approve,-var=foo=bar,-parallelism=10")
//
// Returns:
//   - []string: A slice of individual arguments
//   - error: An error if parsing fails
func parseCommandArgsFromString(argsString string) ([]string, error) {
	if strings.TrimSpace(argsString) == "" {
		return []string{}, nil
	}

	// Split by comma and trim each argument
	rawArgs := strings.Split(argsString, ",")
	args := make([]string, 0, len(rawArgs))

	for _, arg := range rawArgs {
		trimmedArg := strings.TrimSpace(arg)
		if trimmedArg != "" {
			args = append(args, trimmedArg)
		}
	}

	if len(args) == 0 {
		return nil, NewError("no valid arguments found in the provided string")
	}

	return args, nil
}

// buildTerraformCommand constructs a well-formed Terraform command with arguments.
// It validates the command and ensures all arguments are properly formatted.
//
// Parameters:
//   - command: The Terraform command to execute (e.g., "plan", "apply", "destroy")
//   - arguments: Optional arguments to pass to the command
//
// Returns:
//   - []string: A slice representing the complete command to execute
//   - error: An error if the command is invalid or malformed
func buildTerraformCommand(command string, arguments []string) ([]string, error) {
	trimmedCommand := strings.TrimSpace(command)
	if trimmedCommand == "" {
		return nil, NewError("terraform command cannot be empty")
	}

	// Start with "terraform" and the command
	cmd := []string{"terraform", trimmedCommand}

	// Add arguments if provided
	if len(arguments) > 0 {
		for _, arg := range arguments {
			trimmedArg := strings.TrimSpace(arg)
			if trimmedArg != "" {
				cmd = append(cmd, trimmedArg)
			}
		}
	}

	return cmd, nil
}

// DaggerCMD represents a single command with its arguments for execution in a Dagger container.
// It is a slice of strings where the first element is the command and subsequent elements
// are the command arguments.
//
// Example:
//   - []string{"terraform", "init", "-backend=false"} represents: terraform init -backend=false
//   - []string{"terraform", "validate"} represents: terraform validate
//   - []string{"ls", "-la", "/tmp"} represents: ls -la /tmp
//
// This type provides a clean abstraction for building and executing commands within
// Dagger containers while maintaining type safety and readability.
type DaggerCMD []string

// addDaggerCMDs executes a series of commands sequentially on a Dagger container.
//
// This function takes a base Dagger container and applies a series of commands to it,
// returning the modified container. Each command is executed in the order provided,
// and the container state is preserved between command executions.
//
// The function uses Dagger's WithExec method to execute each command, which means:
// - Commands are executed in the container's working directory
// - Environment variables and mounted volumes are preserved between executions
// - Command failures will cause the container build to fail
// - Each command execution creates a new layer in the container
//
// Parameters:
//   - container: The base Dagger container to execute commands on. Must not be nil.
//   - commands: Variable number of DaggerCMD instances representing commands to execute.
//     Each command is executed sequentially in the order provided.
//
// Returns:
//   - *dagger.Container: The modified container after executing all commands.
//     Returns the original container if no commands are provided.
//
// Example Usage:
//
//	container := addDaggerCMDs(baseContainer,
//	  DaggerCMD{"terraform", "init", "-backend=false"},
//	  DaggerCMD{"terraform", "validate"},
//	  DaggerCMD{"terraform", "fmt", "-check"},
//	)
//
// Error Handling:
//
//	This function does not return errors directly. Command execution errors are handled
//	by Dagger's execution engine and will cause the container build to fail at execution time.
func addDaggerCMDs(container *dagger.Container, commands ...DaggerCMD) *dagger.Container {
	modifiedContainer := container

	for _, commandSequence := range commands {
		modifiedContainer = modifiedContainer.WithExec(commandSequence)
	}

	return modifiedContainer
}

// executeDaggerCtrAsync executes a sequence of commands asynchronously on a Dagger container
// and sends the result through a channel for concurrent processing.
//
// This function is designed for concurrent execution patterns where multiple command sequences
// need to be executed in parallel across different containers or working directories.
// It executes all provided commands sequentially on the given container and captures
// the final stdout output.
//
// The function is typically used in scenarios like:
// - Running Terraform commands across multiple modules concurrently
// - Executing validation checks on different directories in parallel
// - Performing compatibility tests across multiple versions simultaneously
//
// Parameters:
//   - ctx: Context for managing the operation's lifecycle and cancellation
//   - resultChan: Write-only channel for sending JobResult. Must not be nil.
//   - baseCtr: The base Dagger container to execute commands on. Must not be nil.
//   - tgWorkDir: Working directory identifier used for result tracking and error reporting
//   - commands: Slice of command slices, where each inner slice represents a complete command
//     with its arguments (e.g., []string{"terraform", "init", "-backend=false"})
//
// Behavior:
//   - Commands are executed sequentially in the order provided
//   - Container state is preserved between command executions
//   - Only the final stdout output is captured and returned
//   - Errors during command execution are wrapped with context information
//   - Results are sent asynchronously through the provided channel
//
// Error Handling:
//   - Command execution errors are captured and included in the JobResult
//   - Errors are wrapped with the working directory context for debugging
//   - The function does not panic on errors but reports them through the result channel
//
// Example Usage:
//
//	resultChan := make(chan JobResult, 1)
//	go executeDaggerCtrAsync(ctx, resultChan, container, "module1", [][]string{
//	  {"terraform", "init"},
//	  {"terraform", "validate"},
//	})
func executeDaggerCtrAsync(
	ctx context.Context,
	resultChan chan<- JobResult,
	baseCtr *dagger.Container,
	tgWorkDir string,
	commands [][]string,
) {
	jobRes := JobResult{WorkDir: tgWorkDir, Output: "", Err: nil}

	execCtr := baseCtr
	for _, command := range commands {
		execCtr = execCtr.
			WithExec(command)
	}

	stdout, err := execCtr.Stdout(ctx)
	jobRes.Output = stdout

	if err != nil {
		jobRes.Err = WrapErrorf(err, "dagger command failed on working directory: %s", tgWorkDir)
	}

	resultChan <- jobRes
}
