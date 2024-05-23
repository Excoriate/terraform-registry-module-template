config {
  module = true
  force  = false
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

rule "terraform_documented_variables" {
  enabled = true
}
rule "terraform_documented_outputs" {
  enabled = true
}
rule "terraform_unused_required_providers" {
  enabled = true
}
