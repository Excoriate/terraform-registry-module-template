//go:build readonly && examples

package examples

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
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

	// Setup phase - Get directory paths using repo utilities
	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Create Terraform options for the test
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
		Upgrade:      true,
		Vars: map[string]interface{}{
			"is_enabled": true,
		},
	}

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

	// Setup phase - Get directory paths using repo utilities
	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Create Terraform options for the test
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
		Upgrade:      true,
	}

	// Log the test context
	t.Logf("🔍 Testing example at directory: %s", terraformOptions.TerraformDir)

	// Execution phase - Initialize the module
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Validate the module to ensure configuration correctness
	validateOutput, err := terraform.ValidateE(t, terraformOptions)
	require.NoError(t, err, "Terraform validate failed")
	t.Log("✅ Terraform Validate Output:\n", validateOutput)

	// Check formatting
	fmtOutput, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "fmt", "-recursive", "-check")
	require.NoError(t, err, "Terraform fmt check failed")
	t.Log("✅ Terraform fmt Output:\n", fmtOutput)
}

// TestPlanningOnBasicExampleWhenModuleDisabled verifies that no resources are planned
// for creation when the module is disabled through the is_enabled flag.
func TestPlanningOnBasicExampleWhenModuleDisabled(t *testing.T) {
	// Enable parallel test execution
	t.Parallel()

	// Setup phase - Get directory paths using repo utilities
	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Create Terraform options with the module disabled
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
		Upgrade:      true,
		Vars: map[string]interface{}{
			"is_enabled": false,
		},
	}

	// Log the test context
	t.Logf("🔍 Testing disabled module at directory: %s", terraformOptions.TerraformDir)

	// Execution phase - Initialize the module
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan the module to verify no resources are created when disabled
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output (Disabled Module):\n", planOutput)
}
