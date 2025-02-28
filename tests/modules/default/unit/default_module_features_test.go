package unit

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestDefaultModuleFeatureEnabled verifies the module works correctly when enabled
func TestDefaultModuleFeatureEnabled(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Resolve repository paths
	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Prepare Terraform options for target configuration
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetTargetDir("default/basic"),
		Vars: map[string]interface{}{
			"is_enabled": true,
		},
	}

	// Log test context
	t.Logf("🔍 Testing module enabled configuration in directory: %s", terraformOptions.TerraformDir)

	// Initialize Terraform
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed for enabled configuration")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan the configuration
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed for enabled configuration")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Add assertions to verify resources are planned when module is enabled
}

// TestDefaultModuleFeatureDisabled verifies the module behaves correctly when disabled
func TestDefaultModuleFeatureDisabled(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Resolve repository paths
	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Prepare Terraform options with module disabled
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetTargetDir("default/basic"),
		Vars: map[string]interface{}{
			"is_enabled": false,
		},
	}

	// Log test context
	t.Logf("🔍 Testing module disabled configuration in directory: %s", terraformOptions.TerraformDir)

	// Initialize Terraform
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed for disabled configuration")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan the configuration
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed for disabled configuration")
	t.Log("📝 Terraform Plan Output (Disabled Module):\n", planOutput)

	// Add assertions to verify no resources are planned when module is disabled
}
