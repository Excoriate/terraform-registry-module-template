output "is_enabled" {
  value       = module.main_module.is_enabled
  description = "Whether the module is enabled or not."
}

output "tags_set" {
  value       = module.main_module.tags_set
  description = "The tags set for the module."
}
