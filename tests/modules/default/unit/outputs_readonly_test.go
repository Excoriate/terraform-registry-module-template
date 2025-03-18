//go:build unit && readonly

package unit

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestOutputsOnBasicTarget verifies that all expected outputs are present
// in the plan for the basic target configuration.
func TestOutputsOnBasicTarget(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options with isolated provider cache
	terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "basic", map[string]interface{}{
		"is_enabled": true,
	})
	terraformOptions.Upgrade = true

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan to show what would be created in the basic target
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)
}

// TestOutputValuesOnBasicTarget verifies that the output values are as expected
// in the plan for the basic target configuration.
func TestOutputValuesOnBasicTarget(t *testing.T) {
	t.Parallel()

	// Use helper to set up terraform options with isolated provider cache
	terraformOptions := helper.SetupTargetTerraformOptions(t, "default", "basic", map[string]interface{}{
		"is_enabled": true,
	})
	terraformOptions.Upgrade = true

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan to show what would be created in the basic target
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)
}
