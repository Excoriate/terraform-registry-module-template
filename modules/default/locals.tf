locals {
  is_enabled = var.is_enabled ? { is_enabled = true } : {}
  // This one is just to be exposed as an output value, also it's required by an upstream terragrunt stack.
  aws_region_to_deploy = var.aws_region
}
