###################################
# Module Resources 🛠️
# ----------------------------------------------------
#
# This section declares the resources that will be created or managed by this Terraform module.
# Each resource is annotated with comments explaining its purpose and any notable configurations.
#
###################################
data "aws_caller_identity" "current" {
  count = local.is_enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.is_enabled ? 1 : 0
}

data "aws_region" "current" {
  count = local.is_enabled ? 1 : 0
}
