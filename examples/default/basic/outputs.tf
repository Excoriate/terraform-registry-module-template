output "is_enabled" {
  description = "Whether the module is enabled or not"
  value       = module.main_module.is_enabled
}

output "tags_set" {
  description = "The tags set for the module"
  value       = module.main_module.tags_set
}
