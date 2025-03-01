//go:build unit && readonly
// +build unit,readonly

package unit

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestInitializationOnModuleWhenUpgradeEnabled verifies that the Terraform module can be successfully initialized
// with upgrade enabled, ensuring compatibility and readiness for deployment.
func TestInitializationOnModuleWhenUpgradeEnabled(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesDir("default"),
		Upgrade:      true,
	}

	t.Logf("🔍 Terraform Module Directory: %s", terraformOptions.TerraformDir)

	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)
}

// TestValidationOnModuleWhenBasicConfiguration ensures that the module
// passes Terraform validation checks, verifying its structural integrity.
func TestValidationOnModuleWhenBasicConfiguration(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesDir("default"),
		Upgrade:      true,
	}

	t.Logf("🔍 Terraform Module Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Validate with detailed error output
	validateOutput, err := terraform.ValidateE(t, terraformOptions)
	require.NoError(t, err, "Terraform validate failed")
	t.Log("✅ Terraform Validate Output:\n", validateOutput)
}

// TestPlanningOnTargetWhenModuleEnabled verifies the Terraform plan generation
// for the basic target configuration when the module is explicitly enabled.
func TestPlanningOnTargetWhenModuleEnabled(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetTargetDir("default", "basic"),
		Upgrade:      true,
		Vars: map[string]interface{}{
			"is_enabled": true,
		},
	}

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan to show what would be created in the basic target
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify plan contains the random_string resource
	require.Contains(t, planOutput, "random_string.random_text", "Plan should include random_string resource")
}
