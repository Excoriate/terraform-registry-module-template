//go:build e2e

package e2e

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestDefaultExamplesE2EBasicDeployment verifies that the basic example
// can be successfully deployed and creates the expected resources.
func TestDefaultExamplesE2EBasicDeployment(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetExamplesDir("default/basic"),
		Upgrade:      true,
		Vars: map[string]interface{}{
			"is_enabled": true,
		},
	}

	// Clean up resources when the test is complete
	defer terraform.Destroy(t, terraformOptions)

	t.Logf("🔍 Testing example deployment in directory: %s", terraformOptions.TerraformDir)

	// Initialize and apply the Terraform configuration
	terraform.InitAndApply(t, terraformOptions)

	// Verify outputs
	isEnabled := terraform.Output(t, terraformOptions, "module_is_enabled")
	require.Equal(t, "true", isEnabled, "Module should be enabled")

	// Additional verification could be done here, such as:
	// - Checking API to confirm resources were created with correct configuration
	// - Validating resource properties match expected values
	// - Testing functionality of the created resources
}
