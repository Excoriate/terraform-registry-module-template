package unit

import (
	"testing"

	"github.com/Excoriate/terraform-registry-module-template/tests/pkg/tf_sources"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

var isEnabledVar = map[string]interface{}{
	"is_enabled": true,
}

var isDisabledVar = map[string]interface{}{
	"is_enabled": false,
}

func getDirs() (*tf_sources.TFSourcesDir, error) {
	return tf_sources.NewTFSourcesDir()
}

func TestSanityChecksOnModule(t *testing.T) {
	t.Parallel()

	dirs, err := getDirs()

	if err != nil {
		t.Fatalf("failed to get Terraform sources directory: %v", err)
	}

	terraformOptions := &terraform.Options{
		TerraformDir: dirs.GetModulesDir("default"),
		Upgrade:      false,
	}

	t.Logf("Terraform module directory: %s", terraformOptions.TerraformDir)

	_, err = terraform.InitE(t, terraformOptions)
	require.NoError(t, err)

	_, err = terraform.ValidateE(t, terraformOptions)
	require.NoError(t, err)
}
