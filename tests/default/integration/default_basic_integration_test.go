package integration

import (
  "testing"

  "github.com/gruntwork-io/terratest/modules/terraform"
)

func getInputVarsValues(t *testing.T, isEnabled bool) map[string]interface{} {
  return map[string]interface{}{}
}

func TestDefaultBasicIntegrationIsDisabled(t *testing.T) {
  t.Parallel()

  terraformOptions := &terraform.Options{
    TerraformDir: "target/basic",
    Vars:         getInputVarsValues(t, true),
    Upgrade:      false,
  }

  terraform.Init(t, terraformOptions)

  terraform.Plan(t, terraformOptions)

  terraform.Apply(t, terraformOptions)
}
