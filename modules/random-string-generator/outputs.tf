###################################
# Module-Specific Outputs 🚀
# ----------------------------------------------------
#
# These outputs are specific to the functionality provided by this module.
# They offer insights and access points into the resources created or managed by this module.
#
###################################
output "random_string" {
  description = "The generated random string based on the specified length, lower, and upper character constraints. Returns 'null' if 'is_enabled' is false."
  value       = local.is_enabled ? random_string.this[0].result : null
}
