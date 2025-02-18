###################################
# Module Resources 🛠️
# ----------------------------------------------------
#
# This section declares the resources that will be created or managed by this Terraform module.
# Each resource is annotated with comments explaining its purpose and any notable configurations.
#
###################################
resource "random_string" "random_text" {
  for_each = local.is_enabled ? { example = true } : {}
  length   = 10
  special  = false
}
