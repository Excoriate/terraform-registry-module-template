###################################
# Test Configuration Outputs
# ----------------------------------------------------
#
# Outputs exposed for test validation
#
###################################

output "is_enabled" {
  value       = module.this.is_enabled
  description = "Whether the module is enabled or not."
}

output "tags_set" {
  value       = module.this.tags_set
  description = "The tags set for the module."
}
