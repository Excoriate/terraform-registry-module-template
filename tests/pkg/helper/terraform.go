package helper

import (
	"testing"
	"time"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/repo"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// SetupTerraformOptions configures Terraform options for a test
func SetupTerraformOptions(t *testing.T, examplePath string, vars map[string]interface{}) *terraform.Options {
	// Get test directory
	dirs, err := repo.NewTFSourcesDir()
	require.NoError(t, err, "Failed to get Terraform sources directory")

	// Configure Terraform options
	return &terraform.Options{
		TerraformDir: dirs.GetExamplesDir(examplePath),
		Vars:         vars,
	}
}

// WaitForResourceDeletion waits for a specified duration to allow for resource deletion
// This helps with eventual consistency issues in AWS
func WaitForResourceDeletion(t *testing.T, duration time.Duration) {
	t.Logf("Waiting %s for resource deletion to propagate...", duration)
	time.Sleep(duration)
}
