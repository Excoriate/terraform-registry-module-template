package helper

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// SetupTerraformOptions configures Terraform options for a test
func SetupTerraformOptions(t *testing.T, examplePath string, vars map[string]interface{}) *terraform.Options {
	// Get test directory
	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Create a unique temporary directory for this test's provider cache
	tempDir, err := os.MkdirTemp("", "tf-plugin-cache-")
	require.NoError(t, err, "Failed to create temporary directory for Terraform provider cache")

	// Clean up the temp directory when the test completes
	t.Cleanup(func() {
		os.RemoveAll(tempDir)
	})

	// Set up environment variables for Terraform
	env := map[string]string{
		"TF_PLUGIN_CACHE_DIR":     tempDir,
		"TF_SKIP_PROVIDER_VERIFY": "1", // Skip provider verification to avoid issues with provider caching
	}

	t.Logf("🔧 Using isolated provider cache at: %s", tempDir)

	// Check if examplePath is a relative path or an absolute path
	var terraformDir string
	if filepath.IsAbs(examplePath) {
		// If it's already an absolute path, use it directly
		terraformDir = examplePath
	} else {
		// If it's a relative path, resolve it using GetExamplesDir
		terraformDir = dirs.GetExamplesDir(examplePath)
	}

	// Configure Terraform options with the isolated provider cache
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars:         vars,
		EnvVars:      env,
	}
}

// SetupTargetTerraformOptions configures Terraform options for unit tests that use target directories
func SetupTargetTerraformOptions(t *testing.T, moduleName, targetName string, vars map[string]interface{}) *terraform.Options {
	// Get test directory
	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Create a unique temporary directory for this test's provider cache
	tempDir, err := os.MkdirTemp("", "tf-plugin-cache-")
	require.NoError(t, err, "Failed to create temporary directory for Terraform provider cache")

	// Clean up the temp directory when the test completes
	t.Cleanup(func() {
		os.RemoveAll(tempDir)
	})

	// Set up environment variables for Terraform
	env := map[string]string{
		"TF_PLUGIN_CACHE_DIR":     tempDir,
		"TF_SKIP_PROVIDER_VERIFY": "1", // Skip provider verification to avoid issues with provider caching
	}

	t.Logf("🔧 Using isolated provider cache at: %s", tempDir)

	// Configure Terraform options with the isolated provider cache
	return &terraform.Options{
		TerraformDir: dirs.GetTargetDir(moduleName, targetName),
		Vars:         vars,
		EnvVars:      env,
	}
}

// SetupModuleTerraformOptions configures Terraform options for testing a module directly with an isolated provider cache.
func SetupModuleTerraformOptions(t *testing.T, moduleDir string, vars map[string]interface{}) *terraform.Options {
	// Create a unique temporary directory for Terraform provider cache
	tempDir, err := os.MkdirTemp("", "tf-plugin-cache-")
	if err != nil {
		t.Fatalf("Failed to create temp dir for Terraform provider cache: %v", err)
	}

	// Set up cleanup to remove the temporary directory after the test completes
	t.Cleanup(func() {
		os.RemoveAll(tempDir)
	})

	// Log the isolated provider cache being used
	t.Logf("🔧 Using isolated provider cache at: %s", tempDir)

	// Configure environment variables for Terraform
	env := map[string]string{
		"TF_PLUGIN_CACHE_DIR":     tempDir,
		"TF_SKIP_PROVIDER_VERIFY": "1", // Skip provider verification to avoid issues with provider caching
	}

	// Return Terraform options with the isolated provider cache
	return &terraform.Options{
		TerraformDir: moduleDir, // Use the module directory directly without duplication
		Vars:         vars,
		EnvVars:      env,
		NoColor:      true,
	}
}

// WaitForResourceDeletion waits for a specified duration to allow for resource deletion
// This helps with eventual consistency issues in AWS
func WaitForResourceDeletion(t *testing.T, duration time.Duration) {
	t.Logf("Waiting %s for resource deletion to propagate...", duration)
	time.Sleep(duration)
}
