//go:build e2e

package e2e

import (
	"testing"
	"time"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestDefaultModuleE2EDeploymentEnabled verifies that the module can be deployed successfully
// when it is enabled. This test performs a full apply and destroy cycle.
func TestDefaultModuleE2EDeploymentEnabled(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesTargetDir("default/basic"),
		Vars: map[string]interface{}{
			"is_enabled": true,
		},
		// Set a longer timeout for apply operations
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		NoColor:            true,
	}

	t.Logf("🔍 Terraform Module Directory: %s", terraformOptions.TerraformDir)

	// Clean up resources when the test completes
	defer terraform.Destroy(t, terraformOptions)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Apply the configuration
	applyOutput, err := terraform.ApplyE(t, terraformOptions)
	require.NoError(t, err, "Terraform apply failed")
	t.Log("✅ Terraform Apply Output:\n", applyOutput)

	// Verify outputs
	isEnabled := terraform.Output(t, terraformOptions, "module_is_enabled")
	require.Equal(t, "true", isEnabled, "Module should be enabled")
}

// TestDefaultModuleE2ETargetBasicDeployment verifies that the basic target configuration
// can be successfully deployed and creates the expected resources.
func TestDefaultModuleE2ETargetBasicDeployment(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetTargetDir("default/basic"),
		Upgrade:      true,
		Vars: map[string]interface{}{
			"is_enabled": true,
		},
	}

	// Clean up resources when the test is complete
	defer terraform.Destroy(t, terraformOptions)

	t.Logf("🔍 Testing target deployment in directory: %s", terraformOptions.TerraformDir)

	// Initialize and apply the Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs
	isEnabled := terraform.Output(t, terraformOptions, "module_is_enabled")
	require.Equal(t, "true", isEnabled, "Module should be enabled")
}

// TestDefaultModuleE2ETargetEnabledKeysDeployment verifies that when the module
// is explicitly enabled with specific tag keys, the resources are created with those tags.
func TestDefaultModuleE2ETargetEnabledKeysDeployment(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesTargetDir("default/enabled_keys"),
		Upgrade:      true,
	}

	// Clean up resources when the test is complete
	defer terraform.Destroy(t, terraformOptions)

	t.Logf("🔍 Testing enabled_keys configuration in directory: %s", terraformOptions.TerraformDir)

	// Initialize and apply the Terraform configuration
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Apply the configuration
	applyOutput, err := terraform.ApplyE(t, terraformOptions)
	require.NoError(t, err, "Terraform apply failed")
	t.Log("✅ Terraform Apply Output:\n", applyOutput)

	// Verify outputs
	isEnabled := terraform.Output(t, terraformOptions, "is_enabled")
	assert.Equal(t, "true", isEnabled, "Module should be enabled")

	// Verify tags were applied correctly
	tags := terraform.OutputMap(t, terraformOptions, "tags")
	assert.Contains(t, tags, "Environment", "Tags should contain Environment")
	assert.Contains(t, tags, "Terraform", "Tags should contain Terraform")
	assert.Contains(t, tags, "Module", "Tags should contain Module")
}

// TestDefaultModuleE2ETargetDisabledConfiguration verifies that when the module
// is explicitly disabled, no resources are created even when the configuration is applied.
func TestDefaultModuleE2ETargetDisabledConfiguration(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesTargetDir("default/disabled_configuration"),
		Upgrade:      true,
	}

	// Clean up resources when the test is complete
	defer terraform.Destroy(t, terraformOptions)

	t.Logf("🔍 Testing disabled configuration in directory: %s", terraformOptions.TerraformDir)

	// Initialize and apply the Terraform configuration
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Apply the configuration
	applyOutput, err := terraform.ApplyE(t, terraformOptions)
	require.NoError(t, err, "Terraform apply failed")
	t.Log("✅ Terraform Apply Output:\n", applyOutput)

	// Verify outputs
	isEnabled := terraform.Output(t, terraformOptions, "is_enabled")
	assert.Equal(t, "false", isEnabled, "Module should be disabled")

	// Verify no resources were created
	assert.Contains(t, applyOutput, "No changes", "Expected apply to contain no changes when module is disabled")
}
