package unit

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestSanityChecksOnModule(t *testing.T) {
	// Parallel execution with unique test names
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Enhanced Terraform options with logging and upgrade
	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesDir("default"),
		Upgrade:      true,
	}

	// Detailed logging of module directory
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
