package unit

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// TestPlanningOnTargetWithCustomTags verifies the Terraform plan generation
// when custom tags are provided to the module.
func TestPlanningOnTargetWithCustomTags(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Define custom tags for testing
	customTags := map[string]interface{}{
		"Environment": "test",
		"Project":     "terraform-module-template",
		"Owner":       "terratest",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetTargetDir("default", "basic"),
		Upgrade:      true,
		Vars: map[string]interface{}{
			"is_enabled": true,
			"tags":       customTags,
		},
	}

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan to show what would be created with custom tags
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify plan contains the random_string resource
	require.Contains(t, planOutput, "random_string.random_text", "Plan should include random_string resource")

	// Verify plan contains the custom tags
	for tagKey, tagValue := range customTags {
		require.Contains(t, planOutput, tagKey, "Plan should include tag key: "+tagKey)
		require.Contains(t, planOutput, tagValue.(string), "Plan should include tag value: "+tagValue.(string))
	}
}

// TestOutputsOnTargetWithCustomTags verifies that the module outputs
// correctly reflect the custom tags provided.
func TestOutputsOnTargetWithCustomTags(t *testing.T) {
	t.Parallel()

	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Define custom tags for testing
	customTags := map[string]interface{}{
		"Environment": "test",
		"Project":     "terraform-module-template",
		"Owner":       "terratest",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetTargetDir("default", "basic"),
		Upgrade:      true,
		Vars: map[string]interface{}{
			"is_enabled": true,
			"tags":       customTags,
		},
	}

	t.Logf("🔍 Terraform Target Directory: %s", terraformOptions.TerraformDir)

	// Initialize with detailed error handling
	initOutput, err := terraform.InitE(t, terraformOptions)
	require.NoError(t, err, "Terraform init failed")
	t.Log("✅ Terraform Init Output:\n", initOutput)

	// Plan to show what would be created with custom tags
	planOutput, err := terraform.PlanE(t, terraformOptions)
	require.NoError(t, err, "Terraform plan failed")
	t.Log("📝 Terraform Plan Output:\n", planOutput)

	// Verify plan contains the expected outputs related to tags
	require.Contains(t, planOutput, "tags_set", "Plan should include tags_set output")
}
