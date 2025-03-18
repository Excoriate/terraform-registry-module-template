//go:build readonly && examples

package examples

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestInitializationOnBasicExampleWhenModuleEnabled verifies that the basic example
// can be initialized and planned successfully when the module is enabled.
// It performs the following steps:
// 1. Sets up the test environment with the basic example directory.
// 2. Initializes the Terraform module.
// 3. Creates a plan with the module enabled.
// 4. Verifies that the plan completes without errors.
func TestInitializationOnBasicExampleWhenModuleEnabled(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Create Terraform options with isolated provider cache
	terraformOptions := helper.SetupTerraformOptions(t, "default/basic", map[string]interface{}{
		"is_enabled": true,
	})
	terraformOptions.Upgrade = true

	// Log the test context
	t.Logf("🔍 Testing example at directory: %s", terraformOptions.TerraformDir)

	// Execution phase - Initialize the module
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan the module to verify configuration
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)
}

// TestValidationOnBasicExampleWhenTerraformInitialized ensures that the basic example
// passes Terraform validation checks, verifying its structural integrity.
func TestValidationOnBasicExampleWhenTerraformInitialized(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Create Terraform options with isolated provider cache
	terraformOptions := helper.SetupTerraformOptions(t, "default/basic", map[string]interface{}{})
	terraformOptions.Upgrade = true

	// Log the test context
	t.Logf("🔍 Testing example at directory: %s", terraformOptions.TerraformDir)

	// Execution phase - Initialize the module
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Validate the module to ensure structural integrity
	validateOutput, err := terraform.ValidateE(t, terraformOptions)
	require.NoError(t, err, "Terraform validation failed")
	t.Log("✅ Terraform Validate Output:\n", validateOutput)
}

// TestPlanningOnBasicExampleWhenModuleDisabled verifies that when the module is disabled,
// no resources are planned for creation, modification, or destruction.
func TestPlanningOnBasicExampleWhenModuleDisabled(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Create Terraform options with isolated provider cache
	terraformOptions := helper.SetupTerraformOptions(t, "default/basic", map[string]interface{}{
		"is_enabled": false,
	})
	terraformOptions.Upgrade = true

	// Log the test context
	t.Logf("🔍 Testing example at directory: %s", terraformOptions.TerraformDir)

	// Execution phase - Initialize the module
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan the module to verify no resources are planned when disabled
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify the plan does not contain resource creation actions
	require.NotContains(t, planOutput, "# module.main_module.random_string.random_text",
		"Plan should not include random_string resource creation when module is disabled")

	// Verify the plan does not include any resource additions
	require.NotContains(t, planOutput, "Plan: 1 to add",
		"Plan should not include any resource additions when module is disabled")

	// Verify is_enabled output is set to false - use more flexible matching to handle color codes
	require.Contains(t, planOutput, "is_enabled = false",
		"Plan should include output is_enabled=false")
}
