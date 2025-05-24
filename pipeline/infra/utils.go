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

func getDefaultAWSRegionIfNotSet(awsRegion string) string {
	if awsRegion == "" {
		return defaultAWSRegion
	}

	return awsRegion
}

func getTerraformModulesExecutionPath(moduleName string) string {
	return filepath.Join(configTerraformModulesRootPath, moduleName)
}

type EnvVarDagger struct {
	Key   string
	Value string
}

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
