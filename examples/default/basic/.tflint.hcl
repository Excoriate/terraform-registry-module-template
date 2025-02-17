config {
  force = false
}

plugin "aws" {
  enabled = true
  version = "0.31.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Core Recommended Rules
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_lookup" {
  enabled = true
}

rule "terraform_empty_list_equality" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = false  # More relaxed for examples
}

rule "terraform_documented_variables" {
  enabled = false  # Optional for examples
}

rule "terraform_documented_outputs" {
  enabled = false  # Optional for examples
}

# Warnings instead of strict rules
rule "terraform_module_version" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

# Disabled or very relaxed rules for examples
rule "terraform_unused_declarations" {
  enabled = false
}

rule "terraform_map_duplicate_keys" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = false  # More flexible for examples
}
