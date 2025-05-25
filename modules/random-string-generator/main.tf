###################################
# Module Resources 🛠️
# ----------------------------------------------------
#
# This section declares the resources that will be created or managed by this Terraform module.
# Each resource is annotated with comments explaining its purpose and any notable configurations.
#
###################################
resource "random_string" "this" {
  count = local.is_enabled ? 1 : 0

  length  = var.length
  lower   = var.lower
  upper   = var.upper
  special = false
  numeric = false
}
