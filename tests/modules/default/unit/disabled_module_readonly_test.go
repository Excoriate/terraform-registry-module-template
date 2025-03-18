//go:build unit && readonly

package unit

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestPlanningOnTargetWhenModuleDisabled verifies that the module
// correctly skips resource creation when disabled via is_enabled = false.
func TestPlanningOnTargetWhenModuleDisabled(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options with isolated provider cache
	terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "disabled_module", nil)
	terraformOptions.Upgrade = true

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan to show what would be created in the disabled_module target
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify plan contains the expected outputs
	require.Contains(t, planOutput, "is_enabled = false", "Plan should show is_enabled output as false")
	require.NotContains(t, planOutput, "random_string.random_text", "Plan should not include random_string resource when module is disabled")
}

// TestOutputsOnTargetWhenModuleDisabled verifies that the module outputs
// are correctly set when the module is disabled.
func TestOutputsOnTargetWhenModuleDisabled(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options with isolated provider cache
	terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "disabled_module", nil)
	terraformOptions.Upgrade = true

	// Add NoColor option for consistent output
	terraformOptions.NoColor = true

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Pre-initialize the module separately to make sure we have the correct module locally
	// This helps with test isolation and module cache issues
	moduleInitOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformOptions.TerraformDir,
		NoColor:      true,
		Lock:         false,
		EnvVars:      terraformOptions.EnvVars,
	})

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, moduleInitOptions)
	require.NoError(t, err, "Terraform module init failed")
	t.Log("✅ Terraform Module Init Output:\n", initOutput)

	// Plan to show what would be created in the disabled_module target
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify plan contains the expected outputs
	require.Contains(t, planOutput, "is_enabled = false", "Plan should show is_enabled output as false")
}
